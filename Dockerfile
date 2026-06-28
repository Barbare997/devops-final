FROM node:20-alpine

RUN apk update && apk upgrade --no-cache

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci --omit=dev \
    && npm cache clean --force \
    && rm -rf /usr/local/lib/node_modules/npm /usr/local/bin/npm /usr/local/bin/npx

COPY src ./src

RUN chown -R node:node /app

ENV NODE_ENV=production
EXPOSE 3000

USER node

CMD ["node", "src/server.js"]
