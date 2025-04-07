# Use official Node.js image
FROM node:18

# Set working directory inside container
WORKDIR /app

# Copy only package files first (better caching)
COPY package*.json ./

# Install dependencies
RUN npm install --legacy-peer-deps

# Copy remaining source code
COPY . .

# Expose the Medusa backend port
EXPOSE 9000

# Start the Medusa server
CMD ["npm", "run", "start"]
