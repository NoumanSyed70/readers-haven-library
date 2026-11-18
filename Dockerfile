# Use Node.js on Alpine to build the website.
FROM node:22-alpine AS builder

# Set the working directory inside the builder stage.
WORKDIR /app

# Copy the npm package files first so dependency installation can be cached.
COPY package*.json ./

# Install the exact dependency versions from package-lock.json.
RUN npm ci

# Copy the HTML source pages.
COPY src/ ./src/

# Copy the shared stylesheet.
COPY styles/ ./styles/

# Build all five pages with Parcel into /app/dist.
RUN npm run build

# Start a fresh runtime stage with Nginx on Alpine.
FROM nginx:1.27-alpine

# Copy the built website into the directory served by Nginx.
COPY --from=builder /app/dist /usr/share/nginx/html

# Document the port on which Nginx listens inside the container.
EXPOSE 80

# Run Nginx in the foreground to keep the container running.
CMD ["nginx", "-g", "daemon off;"]