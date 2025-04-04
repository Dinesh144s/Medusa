# Use official Node.js image
FROM node:18

# Set working directory inside container
WORKDIR /app

# Copy package files first (for better Docker layer caching)
COPY package*.json ./

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy the rest of the source code
COPY . .

# Expose Medusa backend port
EXPOSE 9000

# Start Medusa
CMD ["npm", "run", "start"]

docker build -t $ECR_REPOSITORY ./docker
