#!/usr/bin/env bash
source "$PWD"/oo_jq.sh

Human() {
    local method=$1; shift 1
    # shellcheck disable=SC2034
    local -n selfRef=$1; shift 1
    case $method in
        addYears)
            oo newAge = selfRef . age
            newAge=$((newAge+$1))
            oo selfRef . age = $newAge
    esac
}

mark='{"class": "Human", "age":20}'
oo mark : addYears 3
echo $mark
