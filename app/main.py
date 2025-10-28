from fastapi import FastAPI
from dotenv import load_dotenv

import os
app = FastAPI()
load_dotenv()


@app.get("/health")
async def health():
    return {"status": "ok"}

@app.get("/hello")
async def hello():
    return {"message": f"The environment variable value of of MY_VARIABLE is: {os.getenv('MY_VARIABLE')}"}


@app.get("/love")
async def love():
    return {"message": "Heabin! I love you so much!! I love you and our daughter Sion"}
