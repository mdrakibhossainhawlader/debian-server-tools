#!/bin/bash


exit 0

# Caches

# @TODO Nginx as a reverse proxy for Apache (proxy_cache)

# Nginx - W3 Total Cache/Browser Cache
Cache-Control header
Watcher: nginx.conf

# Nginx - Static file descriptor cache
open_file_cache          max=1000 inactive=20s;
open_file_cache_valid    30s;
open_file_cache_min_uses 2;
open_file_cache_errors   on;

# Nginx - W3 Total Cache/Page Cache/Disk: Enhanced
-> /tmpfs

# FastCGI cache (fastcgi_cache_path)
-> /tmpfs

fastcgi_cache_path /home/user/tmpfs levels=1:2 keys_zone=ZONE:10m inactive=10m;
fastcgi_cache_key "$scheme$request_method$host$request_uri";

fastcgi_cache ZONE;
fastcgi_cache_valid 200 10m;
fastcgi_cache_bypass $query_string $http_pragma;
fastcgi_no_cache $query_string $http_pragma;

# Opcache (php.ini)
opcache.validate_timestamps = 0
;opcache.revalidate_freq = 2

# Object cache for MySQL queries
PHP APCu



git clone https://github.com/perusio/nginx_ensite.git
git clone https://github.com/h5bp/server-configs-nginx.git

https://codex.wordpress.org/Nginx
http://wiki.nginx.org/WordPress


# >>> degenu

# nginx log format
goaccess --agent-list --http-method \
    --geoip-city-data=/var/lib/geoip-database-contrib/GeoLiteCity.dat \
    --log-format='%h %^[%d:%t %^] "%r" %s %b "%R" "%u" "%^"' \
    --date-format='%d/%b/%Y' --time-format='%H:%M:%S' \
    --exclude-ip=SERVER-IP \
    -f nginx-access.log \