FROM node:16 as fe-build
RUN mkidr /frontend
WORKDIR /frontend
COPY . .
RUN npm build
RUN npm run build
FROM ngnix
COPY --from=fe-build /frontend/dist /user/share/nginx/html
