# Usage

To run the `health_check.sh` script, use the following command inside the scripts folder:

```bash
health_check.sh [OPTION] [SERVICES]
```

## Option (optional)

- `--explain`, 
    Explains how to use the services perameters/arguements.

## Example

```bash
health_check.sh --explain cpu
```

This will run the health check on the cpu usage with verbose output and show how to run script with service parameter/arguement.

## Services 

- `all`, 
    Shows ALL available health checks.

- `cpu`, 
    Shows CPU usage.

- `disk`, 
    Shows DISK usage.

- `memory`, 
    Shows MEMORY usage.

## Example

```bash
health_check.sh cpu
```
