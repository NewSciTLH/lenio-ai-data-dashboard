FROM node:24-alpine as build
WORKDIR /app
COPY . /app
RUN : \
  && yarn \
  && yarn build \
  && yarn cache clean \
  && :
EXPOSE 3000
ENTRYPOINT ["yarn", "start"]