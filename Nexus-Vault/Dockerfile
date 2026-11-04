FROM node:24-alpine
WORKDIR /app
COPY package.json package-lock.json server.mjs storage.mjs ./
RUN npm ci --omit=dev
COPY public ./public
RUN mkdir data && chown node:node data
USER node
ENV HOST=0.0.0.0 PORT=3000 NEXUS_DATA_DIR=/app/data
EXPOSE 3000
CMD ["node", "server.mjs"]
