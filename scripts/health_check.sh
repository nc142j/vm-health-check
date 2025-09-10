#!/bin/bash

#services and their descriptions
declare -A SERVICES=(
    ["cpu"]="cpu \t\t checks cpu metrics \t\t Usage: bash health_check.sh cpu"
    ["memory"]="memory \t\t checks memory metrics \t\t Usage: bash health_check.sh memory"
    ["disk"]="disk \t\t checks disk metrics \t\t Usage: bash health_check.sh disk"
    ["all"]="all \t\t checks all metrics \t\t Usage: bash health_check.sh all"
)

# Thresholds
HIGH_CPU_THRESHOLD=85
HIGH_MEMORY_THRESHOLD=90
MEDIUM_MEMORY_THRESHOLD=80
HIGH_DISK_THRESHOLD=80

# Log file setup
LOG_DIR="log"
LOG_FILE="$LOG_DIR/health_checks_$(date +%Y-%m-%d).log"
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\e[32m'
NC='\033[0m' # No Color

create_log_file() {
    # Create log directory if it doesn't exist
    [ ! -d "$LOG_DIR" ] && mkdir -p "$LOG_DIR"
    # Create log file if it doesn't exist
    [ ! -f "$LOG_FILE" ] && touch "$LOG_FILE"
}

write_to_log() {
    local message="$1"
    echo -e "$message" >> "$LOG_FILE"
}

check_cpu() {
    cpu_message="===CPU Usage==="
    echo "$cpu_message"
    write_to_log "$cpu_message"
    cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    echo "$cpu%"
    write_to_log "$cpu%"
    # Remove any % and whitespace before passing to alert_check
    cpu_clean=$(echo "$cpu" | tr -d ' %')
    alert_check cpu "$cpu_clean"
}

check_memory() {
    memory_message="===Memory Usage==="
    echo "$memory_message"
    write_to_log "$memory_message"
    memory=$(free -m | awk '/Mem:/ {print $3 "/" $2 "MB used"}')
    memory_percent=$(free | awk '/Mem:/ {printf("%.2f"), $3/$2 * 100}')
    memory_text=$(echo "$memory : ($memory_percent%)")
    echo "$memory_text"
    write_to_log "$memory_text"
    # Remove any % and whitespace before passing to alert_check
    memory_clean=$(echo "$memory_percent" | tr -d ' %')
    alert_check memory "$memory_clean"
}

check_disk() {
    disk_message="===Disk Usage==="
    echo "$disk_message"
    write_to_log "$disk_message"
    disk=$(df -h / | awk 'NR==2 {print $5" used"}')
    disk_percent=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')
    disk_text=$(echo "$disk : ($disk_percent%)")
    echo "$disk_text"
    write_to_log "$disk_text"
    # Remove any % and whitespace before passing to alert_check
    disk_clean=$(echo "$disk" | tr -d ' %')
    alert_check disk "$disk_percent"
}

alert_check() {
    case $1 in
        cpu)
            cpu_value="$2"
            unset cpu_alert
            if (( $(echo "$cpu_value >= $HIGH_CPU_THRESHOLD" | bc -l) )); then
                cpu_alert=$(echo -e "${RED}ALERT: High CPU USAGE: Threshold is supposed to be less than: $HIGH_CPU_THRESHOLD${NC}")
            else
                cpu_alert=$(echo -e "${GREEN}CPU USAGE is Healthy.${NC}")
            fi
            echo -e "$cpu_alert"
            write_to_log "$cpu_alert"
            unset cpu_alert
            ;;
        memory)
            memory_value="$2"
            unset memory_alert
            if (( $(echo "$memory_value >= $HIGH_MEMORY_THRESHOLD" | bc -l) )); then
                memory_alert=$(echo -e "${RED}ALERT: High MEMORY USAGE: Threshold is supposed be less than: $HIGH_MEMORY_THRESHOLD%${NC}")
               
            elif (( $(echo "$memory_value >= $MEDIUM_MEMORY_THRESHOLD && $memory_value < $HIGH_MEMORY_THRESHOLD" | bc -l) )); then
                memory_alert=$(echo -e "${YELLOW}WARNING: Medium MEMORY USAGE: Threshold is supposed to be less than: $MEDIUM_MEMORY_THRESHOLD%${NC}")
            else
                memory_alert=$(echo -e "${GREEN}MEMORY USAGE is Healthy.${NC}") 
            fi
            echo -e "$memory_alert"
            write_to_log "$memory_alert"
            unset memory_alert
            ;;
        disk)
            disk_value="$2"
            unset disk_alert
            if (( $(echo "$disk_value >= $HIGH_DISK_THRESHOLD" | bc -l) )); then
                disk_alert=$(echo -e "${RED}ALERT: High DISK USAGE: Threshold is supposed to be less than: $HIGH_DISK_THRESHOLD%${NC}")
            else
                disk_alert=$(echo -e "${GREEN}DISK USAGE is Healthy.${NC}")
            fi
            echo -e "$disk_alert"
            write_to_log "$disk_alert"
            unset disk_alert
            ;;
        *)
            return
            ;;
    esac
}

main() {

    create_log_file
    echo "<---------------- $(date '+%Y-%m-%d %H:%M:%S') ----------------> " >> "$LOG_FILE"

    if [ $# -eq 0 ] || [ $# -ge 3 ]; then
        echo "The script has either not enough arguments or too many arguments."
        echo "See Usage: $0 --explain all"
        exit 1
    fi

    if [ "$1" == "--explain" ] && [[ -z "${SERVICES[$2]}" ]]; then
        echo "Invalid service argument: $2"
        echo "Available services: ${!SERVICES[@]}"
        exit 1
    fi

    if [ "$1" == "--explain" ]; then
        if [ "$2" == "all" ]; then
            for service in "${!SERVICES[@]}"; do
                echo -e "${SERVICES[$service]}"
            done
        elif [[ -n "${SERVICES[$2]}" ]]; then
            echo -e "${SERVICES[$2]}"
        else
            echo "Unknown service: $2"
            echo "Available services: ${!SERVICES[@]}"
            exit 1
        fi
        exit 0
    fi

     # If $1 is a valid service, call the appropriate function
    if [[ -n "${SERVICES[$1]}" ]]; then
        case "$1" in
            cpu)
                check_cpu
                ;;
            memory)
                check_memory
                ;;
            disk)
                check_disk
                ;;
            all)
                check_cpu
                check_memory
                check_disk
                ;;
        esac
        exit 0
    else
        echo "Unknown service: $1"
        echo "Available services: ${!SERVICES[@]}"
        exit 1
    fi
}

main "$@"