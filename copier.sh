#!/bin/dash

# if you don't want this, uncomment the next line
# exit 0

while true ; do
  cp -ruv public/* /srv/www/$(whoami)/localhost/
  sleep 1
done
