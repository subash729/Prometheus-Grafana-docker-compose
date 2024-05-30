#!/bin/bash

base_store_dir=$HOME/github-test
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


    echo "Usage: $0 [-s <websitename>] | [-f <source-file>] -o <output file>"
    echo "Options:"
    echo "  -s, --site <websitename>        Website Name"
    echo "  -p, --file <source-file>        File containing website names"
    echo "  -o, --output <output file>      Output file name to save result"
    echo
    print_intermediate "Examples:"
    print_init "  ./new-custom-task.sh -s facebook.com"
    print_init "  ./new-custom-task.sh --file website-list.txt -o final-outputlist"
    print_fail "For more information, contact us:"
    print_success "  Email: pingjiwan@gmail.com,  Phone: +977 9866358671"
    print_success "  Email: subaschy729@gmail.com, Phone: +977 9823827047"
    exit 1
}

# Function to take input from user
taking_input() {
    # Initialize variables with default values
    SITE=""
    FILE=""
    OUTPUT=""

    # Parse command-line options
    while [[ $# -gt 0 ]]; do
        key="$1"
        case $key in
            -s|--site)
                SITE="$2"
                shift # past argument
                shift # past value
                ;;
            -f|--file)
                FILE="$2"
                shift # past argument
                shift # past value
                ;;
            -o|--output)
                OUTPUT="$2"
                shift # past argument
                shift # past value
                ;;
            *)
                # unknown option
                usage
                ;;
        esac
    done

    # Check if at least one of site, file, or output is provided
    if [[ -z $SITE && -z $FILE ]]; then
        echo "Error: Please enter  -s website-name or -f file of website"
        usage
    fi

    # -n checks non empty, concatenating both -s and -f domain name
    if [[ -n $SITE && -n $FILE ]]; then
    # Read from -s input and exclude script's own name
        if [[ -f $FILE ]]; then
            domains="$SITE $(grep -v "$0" "$FILE")"
        else
            domains="$SITE"
        fi
    elif [[ -n $SITE ]]; then
        # Read from -s input
        domains="$SITE"
    elif [[ -n $FILE ]]; then
        # Read from -f input if the file exists
        if [[ -f $FILE ]]; then
            domains=$(grep -v "$0" "$FILE")
        else
            echo "Error: File $FILE does not exist."
            exit 1
        fi
    fi
}

prerequisite_setup() {
    print_init "Creating Scan output Base directory and files at $base_store_dir"
    print_separator
    mkdir -p $base_store_dir
    for domain in $domains; do
        mkdir -p $base_store_dir/$domain
    done

    for domain in $domains; do
        single_file=$base_store_dir/$domain/${domain}__$(date +%Y-%m-%d__%H:%M)__initial_subdomain.txt        
        touch $subdomain_single_file

        array_example+=("$single_file")
    done
}


display_final() {
    print_init "Scanned - Results"
    index=0
    for domain in $domains; do
        print_intermediate "Details about $domain sub-domains"
        single_file=${array_example[$index]}
        echo -n "Total sub-domain: "
        temp=$(wc -l $single_file | cut -d " " -f 1)
        print_intermediate "$temp"
        print_separator
    done
    echo -n  "All Final results are stored at:   "
    print_success "$base_store_dir"
    print_separator

}
cleaning_temp_files() {
    print_separator
    rm -rf $base_store_dir/*initial*.txt 
    print_fail "Unecessary temp files created during scan has been deleted sucessfully"
    print_separator
    print_success "All Tasks are completed sucessfully"
    print_separator
}

main() {
    taking_input "$@"
    prerequisite_setup
    display_final
    cleaning_temp_files

    unset base_store_dir array_example single_file 
    
}
main "$@"
