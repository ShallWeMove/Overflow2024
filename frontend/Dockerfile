# Stage 1: Build the application
FROM node:18-alpine AS builder

# Install pnpm
RUN npm install -g pnpm

WORKDIR /app

COPY pnpm-lock.yaml ./
COPY package.json ./

RUN pnpm install

COPY . .

RUN pnpm run build

CMD ["pnpm", "run", "start"]
