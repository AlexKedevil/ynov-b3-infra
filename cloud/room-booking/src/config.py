import os

APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://roombooking:roombooking@localhost:5432/roombooking",
)
REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")
