# Stage 1: Build the application
FROM node:18-alpine AS builder

# Install pnpm
RUN npm install -g pnpm

WORKDIR /app

COPY pnpm-lock.yaml ./
COPY package.json ./

RUN pnpm install

COPY . .

CMD ["pnpm", "run", "start"]

## Stage 2: Serve the application with nginx
#FROM nginx:alpine
#
## Install OpenSSL
#RUN apk add --no-cache openssl
#
## Remove default nginx website
#RUN rm -rf /usr/share/nginx/html/*
#
## Copy built application from Stage 1
#COPY --from=builder /app/.next /usr/share/nginx/html
#COPY --from=builder /app/public /usr/share/nginx/html
#COPY --from=builder /app/nginx.conf /etc/nginx/nginx.conf
#
## Copy the generated certificates
#COPY certs/localhost.crt /etc/ssl/certs/localhost.crt
#COPY certs/localhost.key /etc/ssl/private/localhost.key
#
## Expose ports
#EXPOSE 80
#EXPOSE 443
#
#CMD ["nginx", "-g", "daemon off;"]
