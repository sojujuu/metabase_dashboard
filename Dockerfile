# Dockerfile
FROM metabase/metabase:latest
# optional, biar hemat RAM di free tier
ENV JAVA_OPTS="-Xmx512m"
EXPOSE 3000
