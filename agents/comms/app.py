import os
import websocket
import time
import threading
from flask import Flask

# --- WebSocket Client Logic ---
# Reads the orchestrator URL from the environment variable set in docker-compose
ORCHESTRATOR_URL = os.environ.get("ORCHESTRATOR_URL")
AGENT_NAME = "Comms Agent (Python)"

def connect_to_orchestrator():
    if not ORCHESTRATOR_URL:
        print(f"[{AGENT_NAME}] ORCHESTRATOR_URL environment variable not set. Cannot connect.")
        return

    print(f"[{AGENT_NAME}] Attempting to connect to {ORCHESTRATOR_URL}...")
    ws = websocket.WebSocketApp(ORCHESTRATOR_URL,
                              on_open=on_ws_open,
                              on_message=on_ws_message,
                              on_error=on_ws_error,
                              on_close=on_ws_close)
    # run_forever will handle reconnects automatically
    ws.run_forever(reconnect=5)

def on_ws_open(ws):
    print(f"[{AGENT_NAME}] Connection to orchestrator established.")
    def send_pings(*args):
        while True:
            try:
                message = f"{AGENT_NAME}: Python agent reporting in."
                ws.send(message)
                time.sleep(5)
            except websocket.WebSocketConnectionClosedException:
                break
    threading.Thread(target=send_pings).start()

def on_ws_message(ws, message):
    print(f"[{AGENT_NAME}] Received message from orchestrator: {message}")

def on_ws_error(ws, error):
    print(f"[{AGENT_NAME}] Orchestrator connection error: {error}")

def on_ws_close(ws, close_status_code, close_msg):
    print(f"[{AGENT_NAME}] Disconnected from orchestrator.")


# --- Flask App (as seen in your original script) ---
# This allows the agent to also have its own API if needed
app = Flask(__name__)

@app.route('/agent/health')
def agent_health():
    return "Agent is alive and running.", 200

# --- Main Execution ---
if __name__ == "__main__":
    # Start the WebSocket client in a background thread
    ws_thread = threading.Thread(target=connect_to_orchestrator)
    ws_thread.daemon = True
    ws_thread.start()

    # Start the Flask server in the main thread
    print(f"[{AGENT_NAME}] Starting Flask server...")
    app.run(host='0.0.0.0', port=5001)
