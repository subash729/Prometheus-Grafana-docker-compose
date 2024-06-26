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
    print_header "prometheus setup"

    echo "Usage: $0 [-c <container_name>] [-d <data_directory>] [-p <port>]"
    echo "Options:"
    echo "  -c, --container <container_name>    Container name to execute"
    echo "  -d, --directory <data_directory>    Optional: Directory to mount into the container"
    echo "  -p, --port <port>                   Port number to expose the service"
    echo
    print_intermediate "Examples:"
    print_init " ./prometheus-setup.sh -c my_container"
    print_init " ./prometheus-setup.sh -c my_container -d /path/to/data"
    print_init " ./prometheus-setup.sh -c my_container -p 9091"
    print_init " ./prometheus-setup.sh -c my_container -d /path/to/data -p 9091"
    print_fail "For more information, contact us:"
    print_success "  Email: pingjiwan@gmail.com,  Phone: +977 9866358671"
    print_success "  Email: subaschy729@gmail.com, Phone: +977 9823827047"
    exit 1
}

# Function to take input from user
taking_input() {
    local container_name=""
    local data_directory=""
    local port="9090"  # Default port

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
            -p|--port)
                port="$2"
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
        data_directory="$HOME/monitoring"
    fi
    if [[ -z $port ]]; then
        port="9090"
    fi

    # Making global variable so that it can be accessed from any functions
    user_container="$container_name"
    user_directory="$data_directory"
    user_port="$port"
}

prerequisite_setup() {
    print_header "1 - Setup"
    print_init "Creating Directory $user_directory and sub-directory for proetheus and grafana"
    print_separator
    sleep 1
    prom_config_dir=$user_directory/prometheus-config
    prom_data_dir=$user_directory/prometheus-backup-data
    grafana_conf_dir=$user_directory/grafana-conf-backup-data
    grafana_dashboard_dir=$user_directory/grafana-dashboard-template
    mkdir -p $prom_config_dir
    mkdir -p $prom_data_dir
    mkdir -p $grafana_conf_dir
    mkdir -p $grafana_dashboard_dir
    print_intermediate "Created directory and all stored files"
    tree -L 2 $user_directory 


    print_intermediate "Copying prometheus config under $user_directory"
    source_code_dir="../source code/prometheus"
    if [ -f "$source_code_dir/prometheus.yml" ]; then
        cp "$source_code_dir"/*.yml "$prom_config_dir"
    else
        cp "source code/prometheus"/*.yml "$user_directory/"
    fi
    print_separator
    print_intermediate "Copying grafana template and data under $user_directory"
    cp "../extra files/grafana-template"/*.json $grafana_dashboard_dir

}

generate_docker_compose() {
    local compose_file="$user_directory/docker-compose.yml"

    print_header "Generating Docker Compose file"
    cat << EOF > "$compose_file"
version: '3.8'
services:
  ${user_container}-prometheus:
    container_name: ${user_container}-prometheus
    image: prom/prometheus
    volumes:
      - prom_data:/etc/prometheus
      - prom_data_backup:/prometheus
    command:
      - "--config.file=/etc/prometheus/prometheus.yml"
      - "--storage.tsdb.path=/prometheus"
    networks:
      - localprom
    ports:
      - "$user_port:9090"

  ${user_container}-grafana:
    container_name: ${user_container}-grafana
    image: grafana/grafana
    volumes:
      - grafana_data:/var/lib/grafana
      - grafana_dashboard:/etc/grafana/provisioning
    environment:
      - GF_SECURITY_ADMIN_PASSWORD=admin
      - GF_SECURITY_ADMIN_USER=admin
    networks:
      - localprom
    ports:
      - "3000:3000"

networks:
  localprom:
    driver: bridge

volumes:
  prom_data:
    driver: local
    driver_opts:
      type: none
      device: $prom_config_dir
      o: bind
  prom_data_backup:
    driver: local
    driver_opts:
      type: none
      device: $prom_data_dir
      o: bind
  grafana_data:
    driver: local
    driver_opts:
      type: none
      device: $grafana_conf_dir
      o: bind
  grafana_dashboard:
    driver: local
    driver_opts:
      type: none
      device: $grafana_dashboard_dir
      o: bind
EOF


    print_success "Docker Compose file generated successfully at: $compose_file"
    print_separator
}

check_files_exist() {
    local compose_file=$user_directory/docker-compose.yml
    local prometheus_file=$prom_config_dir/prometheus.yml

    # Check if docker-compose.yml file exists
    if [[ ! -f $compose_file ]]; then
        echo "Error: docker-compose.yml file not found in $user_directory directory."
        exit 1
    fi

    # Check if prometheus.yml file exists
    if [[ ! -f $prometheus_file ]]; then
        echo "Error: prometheus.yml file not found in $prom_config_dir directory."
        exit 1
    fi
}

docker_compose() {
    cd $user_directory
    print_init "Restarting or updating container using docker compose"
    docker compose up --detach --force-recreate
    print_separator
}


display_final() {
    local_ip=$(hostname -I | awk '{print $1}')
    public_ip=$(curl -s ifconfig.me)
    print_header "PROMETHEUS"
    echo -n  "Container name            :       "
    print_success "${user_container}-prometheus"
    echo -n  "Access GUI locally        :       "
    print_success "http://$local_ip:$user_port/targets"
    echo -n  "Access GUI publicly       :       "
    print_success "http://$public_ip:$user_port/targets"
    echo -n  "Stored file location      :       "
    print_success "$user_directory"
    print_separator
    print_separator
    echo -n  "Access Metrics locally            :       "
    print_success "http://$local_ip:$user_port/metrics"
    echo -n  "Access Metrics publicly           :       "
    print_success "http://$public_ip:$user_port/metrics"
    print_separator
    print_header "GRAFANA"
    echo -n  "Container name            :       "
    print_success "${user_container}-grafana"
    echo -n  "Access GUI locally        :       "
    print_success "http://$local_ip:3000"
    echo -n  "Access GUI publicly       :       "
    print_success "http://$public_ip:3000"
    echo -n  "Stored file location      :       "
    print_success "$user_directory/grafana"
}

main() {
    taking_input "$@"
    prerequisite_setup
    generate_docker_compose
    check_files_exist
    docker_compose
    display_final

    print_success "All tasks are completed successfully!!!"
    print_separator
    unset prom_config_dir prom_data_dir grafana_conf_dir grafana_dashboard_dir
}

main "$@"
