import os
import websocket
import time
import threading
from flask import Flask

ORCHESTRATOR_URL = os.environ.get("ORCHESTRATOR_URL")
AGENT_NAME = "Strategy Agent"

def connect_to_orchestrator():
    if not ORCHESTRATOR_URL:
        print(f"[{AGENT_NAME}] ERROR: ORCHESTRATOR_URL not set.")
        return

    print(f"[{AGENT_NAME}] Attempting to connect to {ORCHESTRATOR_URL}...")
    ws = websocket.WebSocketApp(ORCHESTRATOR_URL, on_open=on_ws_open, on_error=on_ws_error, on_close=on_ws_close)
    ws.run_forever(reconnect=5)

def on_ws_open(ws):
    print(f"[{AGENT_NAME}] Connection established.")
    def send_pings(*args):
        while True:
            try:
                ws.send(f"{AGENT_NAME}: Formulating new long-term objectives.")
                time.sleep(15)
            except websocket.WebSocketConnectionClosedException:
                break
    threading.Thread(target=send_pings, daemon=True).start()

def on_ws_error(ws, error):
    print(f"[{AGENT_NAME}] Connection error: {error}")

def on_ws_close(ws, close_status_code, close_msg):
    print(f"[{AGENT_NAME}] Disconnected.")

app = Flask(__name__)
@app.route('/agent/health')
def agent_health():
    return "Strategy Agent is alive.", 200

if __name__ == "__main__":
    ws_thread = threading.Thread(target=connect_to_orchestrator, daemon=True)
    ws_thread.start()
    print(f"[{AGENT_NAME}] Starting Flask server on port 5004...")
    app.run(host='0.0.0.0', port=5004)
