### STAGE 1: Build ###

# We label our stage as ‘builder’
FROM node:8.1.4-alpine as builder

COPY package.json package-lock.json ./

## Storing node modules on a separate layer will prevent unnecessary npm installs at each build
RUN npm i --silent && mkdir /app && cp -R ./node_modules ./app

WORKDIR /app

COPY . .

## Build the app in production mode and store the artifacts in dist folder
RUN $(npm bin)/gulp default


### STAGE 2: Setup ###

FROM nginx:1.13.8-alpine

## Copy our default nginx config
COPY docker/nginx/default.conf /etc/nginx/conf.d/

## Remove default nginx website
RUN rm -rf /usr/share/nginx/html/*

## From ‘builder’ stage copy over the artifacts in dist folder to default nginx public folder
COPY --from=builder /app/build /usr/share/nginx/html
COPY --from=builder /app/favicon/* /usr/share/nginx/html/
COPY --from=builder /app/googleec25714cc461f707.html /usr/share/nginx/html/

CMD ["nginx", "-g", "daemon off;"]
