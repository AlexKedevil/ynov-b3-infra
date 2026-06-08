import json

import redis

from config import REDIS_URL

_client = None


def get_redis():
    global _client
    if _client is None:
        _client = redis.from_url(REDIS_URL, decode_responses=True)
    return _client


def cache_key(room_id, date_str):
    return f"availability:room:{room_id}:{date_str}"


def get_availability(room_id, date_str):
    data = get_redis().get(cache_key(room_id, date_str))
    return json.loads(data) if data else None


def set_availability(room_id, date_str, slots):
    get_redis().setex(cache_key(room_id, date_str), 300, json.dumps(slots))


def invalidate_availability(room_id, date_str):
    get_redis().delete(cache_key(room_id, date_str))
