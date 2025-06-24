import os
import websocket
import time
import threading
from flask import Flask

# --- WebSocket Client Logic ---
ORCHESTRATOR_URL = os.environ.get("ORCHESTRATOR_URL")
AGENT_NAME = "Research Agent"

def connect_to_orchestrator():
    if not ORCHESTRATOR_URL:
        print(f"[{AGENT_NAME}] ERROR: ORCHESTRATOR_URL environment variable not set. Agent cannot start.")
        return

    print(f"[{AGENT_NAME}] Attempting to connect to {ORCHESTRATOR_URL}...")
    ws = websocket.WebSocketApp(ORCHESTRATOR_URL,
                              on_open=on_ws_open,
                              on_message=on_ws_message,
                              on_error=on_ws_error,
                              on_close=on_ws_close)
    # This will run forever and automatically try to reconnect every 5 seconds
    ws.run_forever(reconnect=5)

def on_ws_open(ws):
    print(f"[{AGENT_NAME}] Connection to orchestrator established.")
    # Start a background thread to send a ping every 7 seconds
    def send_pings(*args):
        while True:
            try:
                message = f"{AGENT_NAME}: Analyzing new data streams."
                ws.send(message)
                time.sleep(7)
            except websocket.WebSocketConnectionClosedException:
                break # Exit the loop if the connection closes
    threading.Thread(target=send_pings, daemon=True).start()

def on_ws_message(ws, message):
    print(f"[{AGENT_NAME}] Received message from orchestrator: {message}")

def on_ws_error(ws, error):
    print(f"[{AGENT_NAME}] Orchestrator connection error: {error}")

def on_ws_close(ws, close_status_code, close_msg):
    print(f"[{AGENT_NAME}] Disconnected from orchestrator.")


# --- Flask App ---
app = Flask(__name__)

@app.route('/agent/health')
def agent_health():
    return "Research Agent is alive.", 200

# --- Main Execution ---
if __name__ == "__main__":
    # Start the WebSocket client in a background thread
    ws_thread = threading.Thread(target=connect_to_orchestrator, daemon=True)
    ws_thread.start()

    # Start the Flask server in the main thread
    print(f"[{AGENT_NAME}] Starting local Flask server on port 5002...")
    app.run(host='0.0.0.0', port=5002)
