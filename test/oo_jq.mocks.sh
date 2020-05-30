#!/usr/local/bin/bash

echo "$(date)" > $PWD/test/oo_jq.log
record() {
    echo "mock $@" >> $PWD/test/oo_jq.log
}

oo() {
    record $FUNCNAME $@
    ooPrivate "$@"
}
export -f oo

get_called() {
    echo $(grep -n "mock $1" $PWD/test/oo_jq.log)
}
