import time

import psycopg2
import psycopg2.extras

from config import DATABASE_URL


def get_connection(max_retries=30, retry_delay=1):
    last_error = None
    for _ in range(max_retries):
        try:
            return psycopg2.connect(DATABASE_URL)
        except psycopg2.OperationalError as exc:
            last_error = exc
            time.sleep(retry_delay)
    raise last_error
