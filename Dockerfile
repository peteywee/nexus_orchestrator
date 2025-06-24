FROM node:20-alpine

# --- ADD THIS LINE TO INSTALL CURL ---
RUN apk add --no-cache curl

WORKDIR /usr/src/app
COPY backend/package*.json ./backend/
RUN npm install --prefix backend
COPY . .
EXPOSE 3000
CMD [ "node", "backend/index.js" ]
