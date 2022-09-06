FROM node:18.8.0-slim

WORKDIR /app

ENV NODE_ENV=production

RUN apt-get update && apt-get install -y procps && rm -rf /var/lib/apt/lists/*

COPY . .

CMD ["node", "lib/main.js"]