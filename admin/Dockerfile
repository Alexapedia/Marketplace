FROM node:20-bookworm-slim AS build
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci
COPY . .
RUN npx ng build --configuration=production

FROM nginx:1.27-alpine
COPY nginx.staging.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist/admin/browser /usr/share/nginx/html
EXPOSE 80
