`#!/usr/local/bin/env bash
source $PWD/oo_jq.sh

Human() {
    local method=$1; shift 1
    local -n self=$1; shift 1
    case $method in
        constructor)
            oo self . class = $FUNCNAME
            oo self . hasEaten = 0
            oo self . meals = '$v'
            self=$(jq --argjson v '[]' '.meals = $v' <<<$self)
            ;;
        eat)
            oo count = self . hasEaten
            count=$((count+1))
            oo self . hasEaten = $count
            local meal=$1
            self=$(jq ".meals += [\"$meal\"]"  <<<$self)
            ;;
        describeYourSelf)
            oo count = self . hasEaten
            oo meals = self . meals
            oo name = self . name
            oo height = self . height
            local -n humanResultRef=$1; shift 1
            humanResultRef="name: $name, height: $height, meals eaten: $count, meals: $meals"
    esac
}
`