FROM node:22-alpine
WORKDIR /app

RUN corepack enable && corepack prepare pnpm@9.1.1 --activate

COPY pnpm-lock.yaml pnpm-workspace.yaml ./
COPY rollup-node/package.json rollup-node/package.json
COPY common common
RUN --mount=type=cache,id=pnpm,target=/root/.local/share/pnpm/store pnpm fetch
COPY rollup-node rollup-node
RUN pnpm install --recursive --frozen-lockfile

EXPOSE 3000

WORKDIR /app/rollup-node
CMD ["pnpm", "start"]
