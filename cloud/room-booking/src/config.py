import os

APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://roombooking:roombooking@localhost:5432/roombooking",
)
REDIS_URL = os.getenv("REDIS_URL", "redis://localhost:6379/0")

# Microsoft Entra ID — API app registration
AZURE_TENANT_ID = os.getenv("AZURE_TENANT_ID", "")
AZURE_CLIENT_ID = os.getenv("AZURE_CLIENT_ID", "")  # room-booking-api
AZURE_SPA_CLIENT_ID = os.getenv("AZURE_SPA_CLIENT_ID", "")  # room-booking-client (SPA)
AZURE_API_AUDIENCE = os.getenv(
    "AZURE_API_AUDIENCE",
    f"api://{AZURE_CLIENT_ID}" if AZURE_CLIENT_ID else "",
)

# Set AUTH_DISABLED=false once Entra is configured
AUTH_DISABLED = os.getenv("AUTH_DISABLED", "true").lower() == "true"
