import logging
from functools import wraps

import jwt
from flask import g, jsonify, request
from jwt import PyJWKClient

from config import (
    AUTH_DISABLED,
    AZURE_API_AUDIENCE,
    AZURE_CLIENT_ID,
    AZURE_TENANT_ID,
)

logger = logging.getLogger("room-booking")

_jwks_client = None


def _auth_configured():
    return bool(AZURE_TENANT_ID and AZURE_CLIENT_ID)


def get_jwks_client():
    global _jwks_client
    if _jwks_client is None:
        jwks_url = (
            f"https://login.microsoftonline.com/{AZURE_TENANT_ID}"
            "/discovery/v2.0/keys"
        )
        _jwks_client = PyJWKClient(jwks_url)
    return _jwks_client


def _valid_audiences():
    audiences = set()
    if AZURE_API_AUDIENCE:
        audiences.add(AZURE_API_AUDIENCE)
    if AZURE_CLIENT_ID:
        audiences.add(AZURE_CLIENT_ID)
        audiences.add(f"api://{AZURE_CLIENT_ID}")
    return list(audiences)


def validate_token(token):
    signing_key = get_jwks_client().get_signing_key_from_jwt(token)
    issuer = f"https://login.microsoftonline.com/{AZURE_TENANT_ID}/v2.0"
    return jwt.decode(
        token,
        signing_key.key,
        algorithms=["RS256"],
        audience=_valid_audiences(),
        issuer=issuer,
    )


def extract_user(claims):
    email = (
        claims.get("preferred_username")
        or claims.get("email")
        or claims.get("upn")
    )
    roles = claims.get("roles", [])
    if isinstance(roles, str):
        roles = [roles]
    return email, roles


def require_auth(required_role=None):
    def decorator(view):
        @wraps(view)
        def wrapped(*args, **kwargs):
            if AUTH_DISABLED or not _auth_configured():
                g.user_email = "dev@smartoffice.local"
                g.user_roles = ["Admin", "Employee"]
                return view(*args, **kwargs)

            auth_header = request.headers.get("Authorization", "")
            if not auth_header.startswith("Bearer "):
                return jsonify({
                    "error": "Authorization header required (Bearer token)",
                }), 401

            token = auth_header[7:]
            try:
                claims = validate_token(token)
                email, roles = extract_user(claims)
                if not email:
                    return jsonify({"error": "token missing user identity"}), 401
                g.user_email = email
                g.user_roles = roles
            except jwt.ExpiredSignatureError:
                return jsonify({"error": "token expired"}), 401
            except jwt.InvalidTokenError as exc:
                logger.warning("Invalid token: %s", exc)
                return jsonify({"error": "invalid token"}), 401

            if required_role and required_role not in g.user_roles:
                return jsonify({
                    "error": f"role '{required_role}' required",
                    "roles": g.user_roles,
                }), 403

            return view(*args, **kwargs)

        return wrapped

    return decorator
