from fastapi import FastAPI
from fastapi.responses import HTMLResponse
from blob_client import update_counter
from logger import get_logger

app = FastAPI()
logger = get_logger()


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/counter")
def counter():
    try:
        count = update_counter()
        logger.info(f"Counter value: {count}")
        return {"counter": count}
    except Exception as e:
        logger.error(f"Error in counter: {str(e)}")
        return {"error": "Failed to update counter", "details": str(e)}


# ✅ Simple UI
@app.get("/", response_class=HTMLResponse)
def home():
    return """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Counter App</title>
        <style>
            body {
                font-family: Arial;
                text-align: center;
                margin-top: 50px;
            }
            button {
                padding: 10px 20px;
                font-size: 16px;
                cursor: pointer;
            }
            #count {
                font-size: 24px;
                margin-top: 20px;
            }
        </style>
    </head>
    <body>
        <h1>🚀 Counter App</h1>
        <button onclick="increment()">Increase Counter</button>
        <div id="count">Click button to load counter</div>

        <script>
            async function increment() {
                const res = await fetch('/counter');
                const data = await res.json();

                if (data.counter !== undefined) {
                    document.getElementById('count').innerText = "Counter: " + data.counter;
                } else {
                    document.getElementById('count').innerText = "Error: " + JSON.stringify(data);
                }
            }
        </script>
    </body>
    </html>
    """