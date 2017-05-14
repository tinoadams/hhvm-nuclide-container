envsubst < /etc/filebeat/filebeat.yml.tpl > /etc/filebeat/filebeat.yml
exec supervisord -n