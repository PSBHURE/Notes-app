FROM nginx:1.23.3-alpine

#  Remove default static HTML page
RUN rm -rf /usr/share/nginx/html/*

#  Replace default Nginx config with our own
RUN rm /etc/nginx/conf.d/default.conf
COPY ./default.conf /etc/nginx/conf.d/default.conf
