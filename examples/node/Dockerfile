FROM node:16-alpine

WORKDIR /usr/src/app

# Copy package files
COPY package*.json ./


# Install dependencies
RUN npm install

# Copy application code
COPY . .

# Set the command to run the application
CMD ["node", "index.js"]
