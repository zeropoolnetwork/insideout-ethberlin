FROM node:22-alpine
WORKDIR /app
COPY rollup-node/package.json rollup-node/pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install
COPY rollup-node .

EXPOSE 4000

CMD ["pnpm", "start"]
