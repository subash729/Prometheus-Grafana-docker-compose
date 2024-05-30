#!/bin/bash

# ------- LARGE Banner display section start

function print_separator {
    printf "\n%s\n" "--------------------------------------------------------------------------------"
}

function print_header {
    figlet -c -f slant "$1"
    print_separator
}

# --------------- LArge Banner display Section end --------------

# Displaying Screen message in color  Start

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
    print_separator
}

# Failures in Red color
function print_fail {
    local message="$1"
    printf "\e[1m\e[31m%s\e[0m\n" "$message"  
    print_separator
}

# -------------Displaying Screen message in color  end ----------------


# ---------- Package installed Function check start -------------
check_figlet_installed() {
    print_separator
    print_header "1 - FIGLET"
    print_separator
    sleep 2
    if command -v figlet &>/dev/null; then
        print_success "Figlet is already installed"  
        return 0
    else
        print_fail "Figlet Package is missing"
        return 1
    fi
}

check_docker_installed() {
    print_separator
    print_header "2 - DOCKER"
    print_separator
    sleep 2

    docker_installed=true
    docker_compose_installed=true

    if command -v docker &>/dev/null; then
        print_success "Docker is already installed"
    else
        print_fail "Docker Package is missing"
        docker_installed=false
    fi

    if docker compose version &>/dev/null; then
        print_success "Docker Compose is already installed"
    else
        print_fail "Docker Compose Package is missing"
        docker_compose_installed=false
    fi

    if [ "$docker_installed" = true ] && [ "$docker_compose_installed" = true ]; then
        return 0
    else
        return 1
    fi
}


# ---------- Package installation start -------------

install_figlet() {
    if check_figlet_installed; then
        return
    fi

    os_description=$(lsb_release -a 2>/dev/null | grep "Description:" | awk -F'\t' '{print $2}')
    print_init "$os_description Detected on your system"
    printf "\n"
    print_intermediate "Installing Figlet"
    print_separator

    if grep -q 'Ubuntu\|Kali' /etc/os-release; then
        sudo apt-get update
        sudo apt-get install -y figlet
        print_separator

        if [ $? -eq 0 ]; then
            print_success "Figlet is now installed"  
        else
            print_fail "Failed to install Figlet"  
        fi

    elif grep -qEi 'redhat|centos' /etc/os-release; then
        sudo yum -y install figlet
        print_separator
        if [ $? -eq 0 ]; then
            print_success "Figlet is now installed"  
        else
            print_fail "Failed to install Figlet"  
        fi

    elif grep -q 'Amazon Linux 2' /etc/os-release || grep -q 'Amazon Linux 3' /etc/os-release; then
        sudo amazon-linux-extras install epel -y
        sudo yum -y install figlet
        print_separator
        if [ $? -eq 0 ]; then
            print_success "Figlet is now installed"  
        else
            print_fail "Failed to install Figlet"  
        fi
    else
        print_separator
        print_fail "Unsupported Linux distribution"  
        exit 1
    fi
}

install_docker() {
    if check_docker_installed; then
        return
    fi

    os_description=$(lsb_release -a 2>/dev/null | grep "Description:" | awk -F'\t' '{print $2}')
    print_init "$os_description Detected on your system"
    printf "\n"
    print_intermediate "Installing docker"
    print_separator

    if grep -q 'Ubuntu' /etc/os-release; then
        sudo apt-get update
        sudo apt-get install -y ca-certificates curl
        sudo install -m 0755 -d /etc/apt/keyrings
        sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
        sudo chmod a+r /etc/apt/keyrings/docker.asc

        # Add the repository to Apt sources:
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
          $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update

        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        print_separator

        if [ $? -eq 0 ]; then
            print_success "docker is now installed"  
        else
            print_fail "Failed to install docker"  
        fi

    elif grep -qEi 'centos' /etc/os-release; then
        sudo yum install -y yum-utils
        sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
        sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        print_separator
        if [ $? -eq 0 ]; then
            print_success "docker is now installed"  
        else
            print_fail "Failed to install docker"  
        fi

    elif grep -q 'Amazon Linux 2' /etc/os-release || grep -q 'Amazon Linux 3' /etc/os-release; then
        sudo amazon-linux-extras install epel -y
        sudo yum -y install docker
        print_separator
        if [ $? -eq 0 ]; then
            print_success "docker is now installed"  
        else
            print_fail "Failed to install docker"  
        fi
    else
        print_separator
        print_fail "Unsupported Linux distribution"  
        exit 1
    fi
}


main() {
    #first package installation
    install_figlet
    # second package install
    install_docker
    
}

main
