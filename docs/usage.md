# Usage

To run the `health_check.sh` script, use the following command inside the scripts folder:

```bash
scripts/health_check.sh [OPTION] [SERVICES]
```

## Option (optional)

- `--explain`, 
    Explains how to use the services parameter/arguements.

## Example

```bash
scripts/health_check.sh --explain cpu
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
scripts/health_check.sh cpu
```

## Logs

Shows the container health usage in ```health_check_(%Year-%Month-%Day).log```

## Example

```cat
log/health_checks_2025-09-09.log 
```

