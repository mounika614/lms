FROM node:16 AS fe-build
RUN mkdir /frontend
WORKDIR /frontend
COPY . .
RUN npm build
RUN npm run build
FROM nginx
COPY --from=fe-build /frontend/dist /usr/share/nginx/html
