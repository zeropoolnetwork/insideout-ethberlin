FROM node:22-alpine AS build
WORKDIR /app
COPY client-app/package.json client-app/pnpm-lock.yaml ./
RUN npm install -g pnpm && pnpm install
COPY client-app .
RUN pnpm build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
