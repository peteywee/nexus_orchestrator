# Stage 1: Install dependencies
FROM node:20-alpine as deps

WORKDIR /app

# Copy the package.json and package-lock.json from the backend
COPY backend/package*.json ./

# Install production dependencies using 'npm ci' for reliability
RUN npm ci

# Stage 2: Create the final production image
FROM node:20-alpine

WORKDIR /app

# Copy the installed node_modules from the 'deps' stage
COPY --from=deps /app/node_modules ./node_modules

# Copy the backend application code
COPY backend .

# Copy the static frontend files into the 'public' directory,
# which the backend will serve.
COPY nexusmind-web-ui ./public

# Expose the port that the backend server will run on
EXPOSE 3000

# The command to start the Node.js backend server
CMD ["node", "index.js"]
