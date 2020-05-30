#!/usr/local/bin/env bash
oo() {
    ooPrivate "$@"
}

ooPrivate() { # mocked in some tests
    local operation=$2
    case $operation in
        '=') # assignment
            if [ "$3" = 'new' ] ; then # instance = new class args
                local ooSelf=$1; shift 3
                local ooClass=$1 ; shift 1
                $ooClass constructor "$ooSelf" "$@"
            elif [ "$4" = '.' ] ; then # result = instance . property
                local -n ooResult=$1; shift 2
                local -n ooSelfRef=$1; shift 2
                local ooProperty=$1
                ooResult=$(jq -r ".$ooProperty" <<<"$ooSelfRef")
            elif [ "$4" = ':' ] ; then # method call with return (result = instance : method args)
                local ooResult=$1; shift 2
                local ooSelf=$1
                local -n ooSelfRef=$1; shift 2
                local ooMethod=$1; shift 1
                local ooSelfCopy=$ooSelfRef
                oo ooClass = ooSelfCopy . class
                $ooClass "$ooMethod" "$ooSelf" "$ooResult" "$@"
            fi
        ;;
        '.') # properties
            local -n ooSelfRef=$1; shift 2
            local instanceProperty=$1;shift 2
            local value=$1;shift 1
            if [[ $ooSelfRef = '' ]] ; then
                ooSelfRef='{}'
            fi
            ooSelfRef=$(jq ".$instanceProperty = \"$value\"" <<<$ooSelfRef)
        ;;
        ':') # methods
            local ooSelf=$1
            local -n ooSelfRef=$1; shift 2
            local ooMethod=$1; shift 1
            # shellcheck disable=SC2034
            local ooSelfCopy="$ooSelfRef"
            oo ooClass = ooSelfCopy . class
            $ooClass "$ooMethod" "$ooSelf" "$@"
        ;;
        *)
            echo "unexpected arguments for oo"
        ;;
    esac
}
