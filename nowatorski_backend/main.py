from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from redis import Redis
import os

app = FastAPI()

origins = ["*"]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


redis_host = os.getenv("REDIS_HOST", "redis")
redis_password = os.getenv("REDIS_PASSWORD", "")

redis_client = Redis(host=redis_host, password=redis_password, decode_responses=True)


@app.get("/api/count/{url}")
async def count_visit(url: str):
    count = redis_client.incr(f"visits:{url}")
    return {"url": url, "visits": count}


@app.get("/api/stats")
async def get_stats():
    keys = redis_client.keys("visits:*")
    stats = {}
    for key in keys:
        url = key.split(":")[1]
        stats[url] = int(redis_client.get(key) or 0)
    return stats
