from redis import Redis
import time

redis_client = Redis(host="redis-service", decode_responses=True)

# Usuń wpisy starsze niż 30 dni
old_keys = redis_client.keys("visits:*")
for key in old_keys:
    last_visit = redis_client.get(key)
    if time.time() - float(last_visit) > 2592000:  # 30 dni
        redis_client.delete(key)