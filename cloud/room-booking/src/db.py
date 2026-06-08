import logging
import time

import psycopg2

from config import DATABASE_URL

logger = logging.getLogger("room-booking")

_schema_ready = False


def get_connection(max_retries=30, retry_delay=1):
    last_error = None
    for _ in range(max_retries):
        try:
            return psycopg2.connect(DATABASE_URL)
        except psycopg2.OperationalError as exc:
            last_error = exc
            time.sleep(retry_delay)
    raise last_error


def bootstrap_schema():
    global _schema_ready
    if _schema_ready:
        return

    ddl = """
    CREATE TABLE IF NOT EXISTS rooms (
        id SERIAL PRIMARY KEY,
        name VARCHAR(100) NOT NULL,
        capacity INT NOT NULL CHECK (capacity > 0),
        floor INT NOT NULL CHECK (floor >= 0)
    );
    CREATE TABLE IF NOT EXISTS users (
        id SERIAL PRIMARY KEY,
        email VARCHAR(255) UNIQUE NOT NULL,
        role VARCHAR(20) NOT NULL DEFAULT 'employee'
            CHECK (role IN ('employee', 'admin'))
    );
    CREATE TABLE IF NOT EXISTS bookings (
        id SERIAL PRIMARY KEY,
        room_id INT NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
        user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
        start_time TIMESTAMPTZ NOT NULL,
        end_time TIMESTAMPTZ NOT NULL,
        CHECK (end_time > start_time)
    );
    CREATE INDEX IF NOT EXISTS idx_bookings_room_time
        ON bookings (room_id, start_time, end_time);
    """

    with get_connection(max_retries=60) as conn:
        with conn.cursor() as cur:
            cur.execute(ddl)
            cur.execute("SELECT COUNT(*) FROM rooms")
            if cur.fetchone()[0] == 0:
                cur.execute(
                    "INSERT INTO rooms (name, capacity, floor) VALUES "
                    "('Salle Alpha', 8, 1), ('Salle Beta', 12, 2), "
                    "('Salle Gamma', 6, 3), ('Salle Delta', 20, 4)"
                )
                cur.execute(
                    "INSERT INTO users (email, role) VALUES "
                    "('admin@smartoffice.local', 'admin'), "
                    "('employee@smartoffice.local', 'employee') "
                    "ON CONFLICT (email) DO NOTHING"
                )
        conn.commit()

    _schema_ready = True
    logger.info("Database schema ready")
