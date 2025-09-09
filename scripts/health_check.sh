#!/bin/bash

declare -A SERVICES=(
    ["cpu"]="cpu \t\t checks cpu metrics \t\t Usage: bash health_check.sh cpu"
    ["memory"]="memory \t\t checks memory metrics \t\t Usage: bash health_check.sh memory"
    ["disk"]="disk \t\t checks disk metrics \t\t Usage: bash health_check.sh disk"
    ["all"]="all \t\t checks all metrics \t\t Usage: bash health_check.sh all"
)

HIGH_CPU_THRESHOLD=85
HIGH_MEMORY_THRESHOLD=90
MEDIUM_MEMORY_THRESHOLD=80
HIGH_DISK_THRESHOLD=80

check_cpu() {
    echo "CPU Usage:"
    cpu=$(top -bn1 | grep "Cpu(s)" | awk '{print $2 + $4}')
    echo "$cpu%"
    # Remove any % and whitespace before passing to alert_check
    cpu_clean=$(echo "$cpu" | tr -d ' %')
    alert_check cpu "$cpu_clean"
}

check_memory() {
    echo "Memory Usage:"
    memory=$(free -m | awk '/Mem:/ {print $3 "/" $2 "MB used"}')
    memory_percent=$(free | awk '/Mem:/ {printf("%.2f"), $3/$2 * 100}')
    echo "$memory : ($memory_percent%)"
    memory_clean=$(echo "$memory_percent" | tr -d ' %')
    alert_check memory "$memory_clean"
}

check_disk() {
    echo "Disk Usage:"
    disk=$(df -h / | awk 'NR==2 {print $5" used"}')
    disk_percent=$(df / | awk 'NR==2 {gsub("%","",$5); print $5}')
    echo "$disk : ($disk_percent%)"
    disk_clean=$(echo "$disk" | tr -d ' %')
    alert_check disk "$disk_percent"
}

alert_check() {
    case $1 in
        cpu)
            cpu_value="$2"
            if (( $(echo "$cpu_value >= $HIGH_CPU_THRESHOLD" | bc -l) )); then
                echo -e "\033[0;31mALERT: High CPU USAGE: Threshold is supposed to be less than: $HIGH_CPU_THRESHOLD%\033[0m"
            fi
            ;;
        memory)
            memory_value="$2"
            if (( $(echo "$memory_value >= $HIGH_MEMORY_THRESHOLD" | bc -l) )); then
                echo -e "\033[0;31mALERT: High MEMORY USAGE: Threshold is supposed be less than: $HIGH_MEMORY_THRESHOLD%\033[0m"
            elif (( $(echo "$memory_value >= $MEDIUM_MEMORY_THRESHOLD && $memory_value < $HIGH_MEMORY_THRESHOLD" | bc -l) )); then
                echo -e "\033[1;33mWARNING: Medium MEMORY USAGE: Threshold is supposed to be less than: $MEDIUM_MEMORY_THRESHOLD%\033[0m"
            fi
            ;;
        disk)
            disk_value="$2"
            if (( $(echo "$disk_value >= $HIGH_DISK_THRESHOLD" | bc -l) )); then
                echo -e "\033[0;31mALERT: High DISK USAGE: Threshold is supposed to be less than: $HIGH_DISK_THRESHOLD%\033[0m"
            fi
            ;;
        *)
            return
            ;;
    esac
}

main() {

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