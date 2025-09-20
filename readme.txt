Create Folder:

mkdir -p /Users/julius/metabase_dashboard/{mysql_data,metabase_data,plugins,mysql_init}

# set permission read/write/execute
chmod -R 777 /Users/julius/metabase_dashboard/mysql_data  

Start:
cd /Users/julius/metabase_dashboard
docker compose pull
docker compose up -d

Watch Log:
docker logs -f mysql
# wait for "ready for connections" and healthcheck to pass
docker logs -f metabase
