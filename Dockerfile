# Use an official Node.js runtime as a parent image
FROM node:18-alpine

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy the backend's package.json and package-lock.json
COPY backend/package*.json ./backend/

# Install backend dependencies
RUN npm install --prefix backend

# Copy the rest of your application code
COPY . .

# Your app binds to port 3000, so expose it
EXPOSE 3000

# Define the command to run your app
CMD [ "node", "backend/index.js" ]
