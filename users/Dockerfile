FROM openresty/openresty:alpine

RUN apk add --no-cache git gcc musl-dev && \
  luarocks install lapis && \
  luarocks install etlua && \
  luarocks install lua-resty-http && \
  luarocks install luasocket && \
  luarocks install lua-cjson

WORKDIR /app

COPY init.lua /app/init.lua

RUN mkdir -p /app/logs && \
  mkdir -p /app/nginx/conf && \
  echo 'worker_processes 1;' > /app/nginx/conf/nginx.conf && \
  echo 'error_log /app/logs/error.log;' >> /app/nginx/conf/nginx.conf && \
  echo 'events { worker_connections 1024; }' >> /app/nginx/conf/nginx.conf && \
  echo 'http {' >> /app/nginx/conf/nginx.conf && \
  echo '    include mime.types;' >> /app/nginx/conf/nginx.conf && \
  echo '    lua_package_path "/app/?.lua;/usr/local/openresty/lualib/?.lua;;";' >> /app/nginx/conf/nginx.conf && \
  echo '    server {' >> /app/nginx/conf/nginx.conf && \
  echo '        listen 5001;' >> /app/nginx/conf/nginx.conf && \
  echo '        lua_code_cache on;' >> /app/nginx/conf/nginx.conf && \
  echo '        location / {' >> /app/nginx/conf/nginx.conf && \
  echo '            default_type text/html;' >> /app/nginx/conf/nginx.conf && \
  echo '            content_by_lua_block {' >> /app/nginx/conf/nginx.conf && \
  echo '                require("lapis").serve("app")' >> /app/nginx/conf/nginx.conf && \
  echo '            }' >> /app/nginx/conf/nginx.conf && \
  echo '        }' >> /app/nginx/conf/nginx.conf && \
  echo '    }' >> /app/nginx/conf/nginx.conf && \
  echo '}' >> /app/nginx/conf/nginx.conf

EXPOSE 5001

CMD ["/usr/local/openresty/nginx/sbin/nginx", "-p", "/app/nginx/", "-c", "conf/nginx.conf"]
