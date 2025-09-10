FROM alpine:latest

WORKDIR /vm-health-check

COPY . .

RUN apk add --no-cache bash procps cronie

# Add cron job to run health_check.sh every 5 minutes
RUN echo "*/1 * * * * cd /vm-health-check && bash /vm-health-check/scripts/health_check.sh all" > /etc/crontabs/root

COPY entrypoint.sh /scripts/entrypoint.sh

RUN chmod +x /scripts/entrypoint.sh

CMD ["/entrypoint.sh"]
