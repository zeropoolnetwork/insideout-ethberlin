FROM node:22-alpine
WORKDIR /app
RUN corepack enable && corepack prepare pnpm@9.1.1 --activate
COPY storage-node/package.json storage-node/pnpm-lock.yaml ./
COPY storage-node .

EXPOSE 3000

CMD ["pnpm", "start"]
