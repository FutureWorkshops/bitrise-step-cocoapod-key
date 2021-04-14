set -e

#=======================================
# Functions
#=======================================

RESTORE='\033[0m'
RED='\033[00;31m'
YELLOW='\033[00;33m'
BLUE='\033[00;34m'
GREEN='\033[00;32m'

function color_echo {
    color=$1
    msg=$2
    echo -e "${color}${msg}${RESTORE}"
}

function echo_fail {
    msg=$1
    echo
    color_echo "${RED}" "${msg}"
    exit 1
}

function echo_warn {
    msg=$1
    color_echo "${YELLOW}" "${msg}"
}

function echo_info {
    msg=$1
    echo
    color_echo "${BLUE}" "${msg}"
}

function echo_details {
    msg=$1
    echo "  ${msg}"
}

function echo_done {
    msg=$1
    color_echo "${GREEN}" "  ${msg}"
}

function validate_required_input {
    key=$1
    value=$2
    if [ -z "${value}" ] ; then
        echo_fail "[!] Missing required input: ${key}"
    fi
}

function validate_required_input_with_options {
    key=$1
    value=$2
    options=$3

    validate_required_input "${key}" "${value}"

    found="0"
    for option in "${options[@]}" ; do
        if [ "${option}" == "${value}" ] ; then
            found="1"
        fi
    done

    if [ "${found}" == "0" ] ; then
        echo_fail "Invalid input: (${key}) value: (${value}), valid options: ($( IFS=$", "; echo "${options[*]}" ))"
    fi
}

function parse_list {
    if [ -z "$2" ]; then
        echo_fail "Failed to split list $1"
    fi
    local -n RESULT_ARRAY=$3
    IFS='|' read -a RESULT_ARRAY <<< "$2"
}

#=======================================
# Main
#=======================================

#
# Validate parameters
echo_info "Configs:"
echo_details "* project_name: ${project_name}"
echo_details "* podfile_path: ${podfile_path}"

validate_required_input "podfile_path" $podfile_path

GEM_COMMAND=""
if [[ -f "Gemfile" || -d ".bundle" ]]; then
    echo_info "Using Gemfile configuration"
    GEM_COMMAND="bundle exec"

    echo_info "Installing bundle"
    bundle install
else
    echo_info "Using system gems"
    GEM_COMMAND=""
fi

echo_info "Installing cocoapods and cocoapods-keys"
eval "$GEM_COMMAND gem install cocoapods cocoapods-keys"
