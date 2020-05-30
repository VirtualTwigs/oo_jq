#!/usr/local/bin/env bats
load "$PWD"/test/libs/bats-support/load.bash
load "$PWD"/test/libs/bats-assert/load.bash
source "$PWD"/oo_jq.sh

setup() {
    source "$PWD"/test/oo_jq.mocks.sh
    echo "setup" >&3
}

teardown() {
    unset oo
    echo "teardown" >&3
}

@test "simplest constructor (oo mark = new Human)" {
    Human() {
        local method=$1; shift 1
        local -n selfRef=$1; shift 1
        case $method in
            constructor)
                oo selfRef . class = Human
        esac
    }

    oo mark = new Human
    
    record 'record mark is a json Human:' \
            $mark

    assert_equal "$(get_called record)" \
        '4:mock record mark is a json Human: '`
        `'{ "class": "Human" }'
 }

@test "constructor with 2 args (oo mark = new Human a b)" {
    Human() {
        local method=$1; shift 1
        local -n selfRef=$1; shift 1
        case $method in
            constructor)
                oo selfRef . class = Human
                oo selfRef . name = "$1"
                oo selfRef . sex = $2
        esac
    }

    oo mark = new Human Jane\ Doe female

    record 'record mark is a json Human with name and sex:' \
            $mark

    assert_equal "$(get_called record)" \
        '6:mock record mark is a json Human with name and sex: '`
        `'{ "class": "Human", '`
          `'"name": "Jane Doe", '`
          `'"sex": "female" }'
 }

 @test "method with no return (oo mark : addYears 3)" {
    Human() {
        local method=$1; shift 1
        local -n selfRef=$1; shift 1
        case $method in
            constructor)
                oo selfRef . class = Human
                oo selfRef . age = 20;;
            addYears)
                oo newAge = selfRef . age
                newAge=$((newAge+$1))
                oo selfRef . age = $newAge
        esac
    }

    oo mark = new Human
    oo mark : addYears 3

    record 'record mark is a json Human of age 23:' \
            $mark

    assert_equal "$(get_called record)" \
        '9:mock record mark is a json Human of age 23: '`
        `'{ "class": "Human", "age": "23" }'
 }

 @test "human inherits from animal" {

    Animal() {
        local method=$1; shift 1
        local -n animalSelfRef=$1; shift 1
        case $method in
            constructor)
                oo animalSelfRef . class = Animal
                oo animalSelfRef . breaths = true;;
            canSpeak)
                local -n answer1=$1; shift 1
                answer1=cannotSpeak
        esac
    }

    Human() {
        local method=$1; shift 1
        local -n humanSelfRef=$1; shift 1
        case $method in
            constructor)
                Animal constructor humanSelfRef
                oo humanSelfRef . class = Human
                oo humanSelfRef . handicap = $1;;
            canSpeak)
                local -n answer1=$1; shift 1
                oo myHandicap = humanSelfRef . handicap
                if [ $myHandicap = 'mute' ] ; then
                    answer1=no
                else
                    answer1=yes
                fi
        esac
    }

    oo mark = new Human blind
    oo joe = new Human mute
    oo fido = new Animal
    echo $mark
    echo $joe
    echo $fido

    oo answer2 = mark : canSpeak; assert_equal $answer2 yes
    oo answer2 = joe : canSpeak; assert_equal $answer2 no
    oo answer2 = fido : canSpeak; assert_equal $answer2 cannotSpeak

    record 'record mark is a json Human:' $mark
    record 'record joe is a json Human:' $joe
    record 'record fido is a json Animal:' $fido

    assert_equal "$(get_called record)" \
         '23:mock record mark is a json Human: '`
            `'{ "class": "Human", "breaths": "true", "handicap": "blind" } '`
        `'24:mock record joe is a json Human: '`
            `'{ "class": "Human", "breaths": "true", "handicap": "mute" } '`
        `'25:mock record fido is a json Animal: '`
            `'{ "class": "Animal", "breaths": "true" }'
   }

@test "human has eyes (aggregation)" {

    Eyes() {
        local method=$1; shift 1
        local -n eyesSelfRef=$1; shift 1
        case $method in
            constructor)
                oo eyesSelfRef . class = Eyes
                oo eyesSelfRef . color = brown;;
            canSee)
                local -n answer1=$1; shift 1
                answer1=yes
        esac
    }

    Human() {
        local method=$1; shift 1
        local -n humanSelfRef=$1; shift 1
        case $method in
            constructor)
                oo myEyes = new Eyes
                oo humanSelfRef . class = Human
                humanSelfRef=$(jq --argjson v "$myEyes" '.eyes = $v' <<<$humanSelfRef)
        esac
    }

    oo mark = new Human
    oo marksEyes = mark . eyes
    oo markCanSee = marksEyes : canSee
    record 'record mark is a json Human:' $mark
    record 'record marksEyes is a json Eyes obj:' $marksEyes

    assert_equal $markCanSee yes
    assert_equal "$(get_called record)" \
            '10:mock record mark is a json Human: '`
                `'{ "class": "Human", '`
                `'"eyes": { "class": "Eyes", "color": "brown" } } '`
            `'11:mock record marksEyes is a json Eyes obj: '`
                `'{ "class": "Eyes", "color": "brown" }'
}

@test "using objects directly (without a constructor)" {
    Human() {
        local method=$1; shift 1
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

    record 'record mark is a json Human of age 23:' \
            $mark

    assert_equal "$(get_called record)" \
        '6:mock record mark is a json Human of age 23: '`
        `'{ "class": "Human", "age": "23" }'
 }

