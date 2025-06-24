# Start with a clean Python image
FROM python:3.9-slim

# Set the working directory for the agent
WORKDIR /app

# Copy and install the requirements first
# This is a best practice that speeds up future builds
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the agent's Python code
COPY . .

# Set the command to run when the container starts
CMD ["python", "agent_app.py"]

