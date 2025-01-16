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
    origins=["*"],
)


redis_host = os.getenv("REDIS_HOST", "redis")
redis_password = os.getenv("REDIS_PASSWORD", "")
redis_port = int(os.getenv("REDIS_PORT", "6379"))
app_version = os.getenv("APP_VERSION", "1.0")
app_grade = os.getenv("APP_GRADE", "4.0")

redis_client = Redis(
    host=redis_host, port=redis_port, password=redis_password, decode_responses=True
)


@app.get("/api")
async def api_root():
    return {"message": "API is working!"}


@app.get("/api/health")
async def health_check():
    try:
        redis_client.ping()
        return {"status": "healthy", "redis": "connected"}
    except Exception as e:
        return {"status": "unhealthy", "error": str(e)}


@app.get("/api/version")
async def get_version():
    return {"version": app_version}


@app.get("/api/grade")
async def get_grade():
    return {"grade": app_grade}


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
