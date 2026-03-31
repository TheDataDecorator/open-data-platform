from flask import Flask, jsonify
from flask_cors import CORS
import docker
from datetime import datetime

app = Flask(__name__)
CORS(app)

client = docker.from_env()


def get_uptime(container):
    try:
        started_at = container.attrs["State"]["StartedAt"]
        started = datetime.fromisoformat(started_at.replace("Z", "+00:00"))
        delta = datetime.now(started.tzinfo) - started
        return str(delta).split(".")[0]  # clean hh:mm:ss
    except Exception:
        return "unknown"


@app.route("/status")
def status():
    result = {}

    for c in client.containers.list(all=True):
        name = c.name

        state = c.attrs.get("State", {})

        result[name] = {
            "status": c.status,  # running, exited, etc.
            "health": state.get("Health", {}).get("Status", "n/a"),
            "image": c.image.tags[0] if c.image.tags else "unknown",
            "uptime": get_uptime(c),
            "restart_count": state.get("RestartCount", 0)
        }

    return jsonify(result)


@app.route("/service/<name>/restart", methods=["POST"])
def restart(name):
    try:
        c = client.containers.get(name)
        c.restart()
        return jsonify({"result": "restarted", "service": name})
    except Exception as e:
        return jsonify({"error": str(e)}), 404


@app.route("/")
def home():
    return {
        "status": "docker-status-api running",
        "endpoints": [
            "/status",
            "/service/<name>/restart"
        ]
    }


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=9000)