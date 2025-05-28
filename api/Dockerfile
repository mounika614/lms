# Use a lighter Node.js image for production
FROM node:16

# Set the working directory
WORKDIR /backend

# Copy package.json and package-lock.json (if present)
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy application code (including prisma directory)
COPY . .

# Generate Prisma client
RUN npx prisma generate
# REMOVE THE NEXT LINE: RUN npx prisma db push

# Build the TypeScript application
RUN npm run build

# Expose the port your backend runs on
EXPOSE 8080

# Command to run the application
CMD [ "npm", "start" ]