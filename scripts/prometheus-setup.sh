#!/bin/bash

declare -a array_example # for initial all subdomains

# ------- LARGE Banner display section start
function print_separator {
    printf "\n%s\n" "--------------------------------------------------------------------------------"
}

function print_header {
    figlet -c -f slant "$1"
    print_separator
}

# --------------- Large Banner display Section end --------------

# Displaying Screen message in color Start

# Detection in Yellow color
function print_init {
    local message="$1"
    printf "\e[33m%s\e[0m\n" "$message"
}

# Intermediate in Blue color
function print_intermediate {
    local message="$1"
    printf "\e[34m%s\e[0m\n" "$message"
}

# Completion in Green color
function print_success {
    local message="$1"
    printf "\e[1m\e[32m%s\e[0m\n" "$message"
}

# Failures in Red color
function print_fail {
    local message="$1"
    printf "\e[1m\e[31m%s\e[0m\n" "$message"
}

# -------------Displaying Screen message in color end ----------------

usage() {
    print_header "Scan and Filter Subdomains"

    echo "Usage: $0 [-c <container_name>] [-d <data_directory>]"
    echo "Options:"
    echo "  -c, --container <container_name>    Container name to execute"
    echo "  -d, --directory <data_directory>    Optional: Directory to mount into the container"
    echo
    print_intermediate "Examples:"
    print_init "  prometheus-setup.sh -c my_container"
    print_init "  prometheus-setup.sh -c my_container -d /path/to/data"
    print_fail "For more information, contact us:"
    print_success "  Email: pingjiwan@gmail.com,  Phone: +977 9866358671"
    print_success "  Email: subaschy729@gmail.com, Phone: +977 9823827047"
    exit 1
}

# Function to take input from user
taking_input() {
    local container_name=""
    local data_directory=""

    # Parse command-line options
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            -c|--container)
                container_name="$2"
                shift # past argument
                shift # past value
                ;;
            -d|--directory)
                data_directory="$2"
                shift # past argument
                shift # past value
                ;;
            *)
                # unknown option
                usage
                ;;
        esac
    done

    # Check if container name is provided
    if [[ -z $container_name ]]; then
        echo "Error: Container name is required."
        usage
    fi

    # If data directory is not provided, use container name
    if [[ -z $data_directory ]]; then
        data_directory="$HOME/prometheus"
    fi
}

prerequisite_setup() {
    print_header "1 - Setup"

    print_init "Creating Directory $data_directory"
    print_separator
    mkdir -p $data_directory

    print_intermediate "Copying prometheus.yml to $data_directory"
    cp "../source code/prometheus/prometheus.yml" $data_directory/prometheus.yml
}

generate_docker_compose() {
    local compose_file="$data_directory/docker-compose.yml"

    print_header "Generating Docker Compose file"

    cat << EOF > "$compose_file"
version: '3'
services:
  $container_name:
    image: prom/prometheus
    volumes:
      - prom_data:/etc/prometheus
    networks:
      - localprom
    ports:
      - 9090:9090

networks:
  localprom:
    driver: bridge

volumes:
  web_data:
  prom_data:
    driver: local
    driver_opts:
      type: none
      device: $data_directory
      o: bind
EOF

    print_success "Docker Compose file generated successfully at: $compose_file"
    print_separator
}

check_files_exist() {
    local compose_file=$data_directory/docker-compose.yml
    local prometheus_file=$data_directory/prometheus.yml

    # Check if docker-compose.yml file exists
    if [[ ! -f $compose_file ]]; then
        echo "Error: docker-compose.yml file not found in $data_directory directory."
        exit 1
    fi

    # Check if prometheus.yml file exists
    if [[ ! -f $prometheus_file ]]; then
        echo "Error: prometheus.yml file not found in $data_directory directory."
        exit 1
    fi
}

docker_compose() {
    cd $data_directory
    docker compose up -d &
    sleep 5
    docker compose down
}

display_final() {
    print_header "Results"
    echo -n  "All Final results are stored at:   "
    print_success "$data_directory"
    print_separator
}

main() {
    taking_input "$@"
    prerequisite_setup
    check_files_exist
    generate_docker_compose
    docker_compose
    display_final

    print_success "All Tasks are completed successfully"
    print_separator
}

main "$@"
