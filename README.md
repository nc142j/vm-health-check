# VM Health Check

A bash script that checks key system parameters—CPU usage, memory, and disk space-and reports health status.

# Docker Container Usage

To run the docker linux container, you must run the following command

1. ```docker compose up -d```

***Note: You can run the docker command assuming you have docker & docker desktop installed

Once Linux container is running, run to go inside the container:

2. ```docker exec -it vm-health-check bash```

# See Usage InSide Container

[Usage Instructions](docs/usage.md)


# Exit Container

3. ```exit``` then press enter

# Stop Container

4. ```docker stop vm-health-check```