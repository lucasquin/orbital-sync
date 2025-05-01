FROM openresty/openresty:alpine

RUN apk add --no-cache git gcc musl-dev lua5.1 lua5.1-dev openssl-dev make wget curl ca-certificates && \
  update-ca-certificates && \
  wget https://luarocks.org/releases/luarocks-3.9.2.tar.gz && \
  tar zxpf luarocks-3.9.2.tar.gz && \
  cd luarocks-3.9.2 && \
  ./configure --lua-version=5.1 && \
  make && \
  make install && \
  cd .. && \
  rm -rf luarocks-3.9.2 luarocks-3.9.2.tar.gz

RUN luarocks install lapis || (wget https://luarocks.org/manifests/leafo/lapis-1.16.0-1.rockspec && luarocks install lapis-1.16.0-1.rockspec) && \
  luarocks install etlua || (wget https://luarocks.org/manifests/leafo/etlua-1.3.0-1.rockspec && luarocks install etlua-1.3.0-1.rockspec) && \
  luarocks install lua-resty-http || (wget https://luarocks.org/manifests/pintsized/lua-resty-http-0.17.1-0.rockspec && luarocks install lua-resty-http-0.17.1-0.rockspec) && \
  luarocks install luasocket || (wget https://luarocks.org/manifests/lunarmodules/luasocket-3.1.0-1.rockspec && luarocks install luasocket-3.1.0-1.rockspec) && \
  luarocks install lua-cjson || (wget https://luarocks.org/manifests/openresty/lua-cjson-2.1.0.10-1.rockspec && luarocks install lua-cjson-2.1.0.10-1.rockspec)

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
  echo '        listen 5000;' >> /app/nginx/conf/nginx.conf && \
  echo '        lua_code_cache on;' >> /app/nginx/conf/nginx.conf && \
  echo '        location / {' >> /app/nginx/conf/nginx.conf && \
  echo '            default_type text/html;' >> /app/nginx/conf/nginx.conf && \
  echo '            content_by_lua_block {' >> /app/nginx/conf/nginx.conf && \
  echo '                require("lapis").serve("app")' >> /app/nginx/conf/nginx.conf && \
  echo '            }' >> /app/nginx/conf/nginx.conf && \
  echo '        }' >> /app/nginx/conf/nginx.conf && \
  echo '    }' >> /app/nginx/conf/nginx.conf && \
  echo '}' >> /app/nginx/conf/nginx.conf
EXPOSE 5000

CMD ["/usr/local/openresty/nginx/sbin/nginx", "-p", "/app/nginx/", "-c", "conf/nginx.conf"]
