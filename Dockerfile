FROM node:22-alpine AS workspace
WORKDIR /app

RUN corepack enable && corepack prepare pnpm@9.1.1 --activate

COPY pnpm-lock.yaml .
RUN --mount=type=cache,id=pnpm,target=/root/.local/share/pnpm/store pnpm fetch

COPY . .
RUN pnpm install --recursive --frozen-lockfile


## Create minimal deployment for given package

FROM workspace AS pruned
ARG service
WORKDIR /app
RUN pnpm --recursive run build
RUN pnpm --filter ${service} deploy --prod pruned



## Production image

FROM node:22-alpine
WORKDIR /app

ENV NODE_ENV=production

COPY --from=pruned /app/pruned/dist dist
COPY --from=pruned /app/pruned/package.json package.json
COPY --from=pruned /app/pruned/node_modules node_modules

ENTRYPOINT ["node", "dist"]
