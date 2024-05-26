FROM node:22-alpine AS build
WORKDIR /app

ARG PUBLIC_ROLLUP_API_URL
ENV PUBLIC_ROLLUP_API_URL $PUBLIC_ROLLUP_API_URL

ARG PUBLIC_NODE_API_URL
ENV PUBLIC_NODE_API_URL $PUBLIC_NODE_API_URL

RUN corepack enable && corepack prepare pnpm@9.1.1 --activate
COPY ./pnpm-lock.yaml pnpm-workspace.yaml ./
COPY client-app/package.json client-app/package.json
COPY common common
RUN --mount=type=cache,id=pnpm,target=/root/.local/share/pnpm/store pnpm fetch
COPY client-app client-app
RUN pnpm install --recursive --frozen-lockfile
RUN pnpm --recursive build 

FROM nginx:alpine
COPY client-app/nginx/nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/client-app/build /usr/share/nginx/html

EXPOSE 80 3002

CMD ["nginx", "-g", "daemon off;"]
