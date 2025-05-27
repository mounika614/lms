FROM node:16
WORKDIR /backend
COPY . .
RUN npm install
RUN npx prisma generate
RUN npx prisma db push
RUN npm run build
EXPOSE 8080
CMD ["node","build/index.js"]
