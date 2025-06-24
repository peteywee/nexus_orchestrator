# Start with a Python base image
FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the requirements file first and install dependencies
# This caches the dependency installation step, speeding up future builds
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Now copy the rest of your agent's source code
COPY . .

# The command to run your Python application
CMD ["python", "agent_app.py"]
