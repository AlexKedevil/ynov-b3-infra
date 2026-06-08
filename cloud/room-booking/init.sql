CREATE TABLE IF NOT EXISTS rooms (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    capacity INT NOT NULL CHECK (capacity > 0),
    floor INT NOT NULL CHECK (floor >= 0)
);

CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    role VARCHAR(20) NOT NULL DEFAULT 'employee' CHECK (role IN ('employee', 'admin'))
);

CREATE TABLE IF NOT EXISTS bookings (
    id SERIAL PRIMARY KEY,
    room_id INT NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
    user_id INT NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    start_time TIMESTAMPTZ NOT NULL,
    end_time TIMESTAMPTZ NOT NULL,
    CHECK (end_time > start_time)
);

CREATE INDEX idx_bookings_room_time ON bookings (room_id, start_time, end_time);

INSERT INTO rooms (name, capacity, floor) VALUES
    ('Salle Alpha', 8, 1),
    ('Salle Beta', 12, 2),
    ('Salle Gamma', 6, 3),
    ('Salle Delta', 20, 4);

INSERT INTO users (email, role) VALUES
    ('admin@smartoffice.local', 'admin'),
    ('employee@smartoffice.local', 'employee');
