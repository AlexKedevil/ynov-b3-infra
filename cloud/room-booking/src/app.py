import logging
import os
from datetime import datetime

from flask import Flask, jsonify, request

from cache import get_availability, invalidate_availability, set_availability
from config import APP_VERSION
from db import get_connection

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
)
logger = logging.getLogger("room-booking")


def create_app():
    app = Flask(__name__)

    @app.get("/health")
    def health():
        return jsonify({
            "service": "room-booking",
            "version": APP_VERSION,
            "status": "healthy",
            "project": "Smart Office 2.0",
        })

    @app.get("/rooms")
    def list_rooms():
        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    "SELECT id, name, capacity, floor FROM rooms ORDER BY floor, name"
                )
                rows = cur.fetchall()
        return jsonify([
            {"id": r[0], "name": r[1], "capacity": r[2], "floor": r[3]}
            for r in rows
        ])

    @app.post("/rooms")
    def create_room():
        data = request.get_json(silent=True) or {}
        name = data.get("name")
        capacity = data.get("capacity")
        floor = data.get("floor")

        if not name or capacity is None or floor is None:
            return jsonify({"error": "name, capacity and floor are required"}), 400

        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    "INSERT INTO rooms (name, capacity, floor) VALUES (%s, %s, %s) "
                    "RETURNING id, name, capacity, floor",
                    (name, capacity, floor),
                )
                row = cur.fetchone()
            conn.commit()

        logger.info("Room created id=%s name=%s", row[0], row[1])
        return jsonify({
            "id": row[0], "name": row[1], "capacity": row[2], "floor": row[3],
        }), 201

    @app.get("/bookings")
    def list_bookings():
        room_id = request.args.get("room_id", type=int)
        date_str = request.args.get("date")

        query = (
            "SELECT b.id, b.room_id, r.name, u.email, b.start_time, b.end_time "
            "FROM bookings b "
            "JOIN rooms r ON r.id = b.room_id "
            "JOIN users u ON u.id = b.user_id "
        )
        params = []
        clauses = []

        if room_id:
            clauses.append("b.room_id = %s")
            params.append(room_id)
        if date_str:
            clauses.append("b.start_time::date = %s")
            params.append(date_str)

        if clauses:
            query += "WHERE " + " AND ".join(clauses) + " "
        query += "ORDER BY b.start_time"

        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(query, params)
                rows = cur.fetchall()

        return jsonify([
            {
                "id": r[0],
                "room_id": r[1],
                "room_name": r[2],
                "user_email": r[3],
                "start_time": r[4].isoformat(),
                "end_time": r[5].isoformat(),
            }
            for r in rows
        ])

    @app.get("/rooms/<int:room_id>/availability")
    def room_availability(room_id):
        date_str = request.args.get("date")
        if not date_str:
            return jsonify({"error": "date query parameter is required (YYYY-MM-DD)"}), 400

        cached = get_availability(room_id, date_str)
        if cached is not None:
            return jsonify({"room_id": room_id, "date": date_str, "bookings": cached, "cached": True})

        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT id FROM rooms WHERE id = %s", (room_id,))
                if not cur.fetchone():
                    return jsonify({"error": "room not found"}), 404

                cur.execute(
                    "SELECT start_time, end_time FROM bookings "
                    "WHERE room_id = %s AND start_time::date = %s ORDER BY start_time",
                    (room_id, date_str),
                )
                rows = cur.fetchall()

        slots = [
            {"start_time": r[0].isoformat(), "end_time": r[1].isoformat()}
            for r in rows
        ]
        set_availability(room_id, date_str, slots)
        return jsonify({"room_id": room_id, "date": date_str, "bookings": slots, "cached": False})

    @app.post("/bookings")
    def create_booking():
        data = request.get_json(silent=True) or {}
        room_id = data.get("room_id")
        user_email = data.get("user_email")
        start_time = data.get("start_time")
        end_time = data.get("end_time")

        if not all([room_id, user_email, start_time, end_time]):
            return jsonify({
                "error": "room_id, user_email, start_time and end_time are required",
            }), 400

        try:
            start_dt = datetime.fromisoformat(start_time.replace("Z", "+00:00"))
            end_dt = datetime.fromisoformat(end_time.replace("Z", "+00:00"))
        except ValueError:
            return jsonify({"error": "invalid datetime format (use ISO 8601)"}), 400

        if end_dt <= start_dt:
            return jsonify({"error": "end_time must be after start_time"}), 400

        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute("SELECT id FROM rooms WHERE id = %s", (room_id,))
                if not cur.fetchone():
                    return jsonify({"error": "room not found"}), 404

                cur.execute(
                    "INSERT INTO users (email) VALUES (%s) "
                    "ON CONFLICT (email) DO UPDATE SET email = EXCLUDED.email "
                    "RETURNING id",
                    (user_email,),
                )
                user_id = cur.fetchone()[0]

                cur.execute(
                    "SELECT id FROM bookings WHERE room_id = %s "
                    "AND start_time < %s AND end_time > %s",
                    (room_id, end_dt, start_dt),
                )
                if cur.fetchone():
                    return jsonify({"error": "room already booked for this time slot"}), 409

                cur.execute(
                    "INSERT INTO bookings (room_id, user_id, start_time, end_time) "
                    "VALUES (%s, %s, %s, %s) "
                    "RETURNING id, room_id, start_time, end_time",
                    (room_id, user_id, start_dt, end_dt),
                )
                row = cur.fetchone()
            conn.commit()

        date_str = start_dt.date().isoformat()
        invalidate_availability(room_id, date_str)

        logger.info(
            "Booking created id=%s room=%s user=%s",
            row[0], room_id, user_email,
        )
        return jsonify({
            "id": row[0],
            "room_id": row[1],
            "user_email": user_email,
            "start_time": row[2].isoformat(),
            "end_time": row[3].isoformat(),
        }), 201

    @app.delete("/bookings/<int:booking_id>")
    def delete_booking(booking_id):
        with get_connection() as conn:
            with conn.cursor() as cur:
                cur.execute(
                    "SELECT room_id, start_time FROM bookings WHERE id = %s",
                    (booking_id,),
                )
                row = cur.fetchone()
                if not row:
                    return jsonify({"error": "booking not found"}), 404

                cur.execute("DELETE FROM bookings WHERE id = %s", (booking_id,))
            conn.commit()

        invalidate_availability(row[0], row[1].date().isoformat())
        logger.info("Booking deleted id=%s", booking_id)
        return jsonify({"deleted": booking_id})

    @app.get("/")
    def root():
        return health()

    return app


app = create_app()

if __name__ == "__main__":
    port = int(os.getenv("PORT", "8080"))
    logger.info("Room Booking Service starting on port %s", port)
    app.run(host="0.0.0.0", port=port)
