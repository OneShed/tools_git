#!/bin/bash

set -e 
set -u

branch=$1

is_live() {

    cycle="${1}"

    dirname=$(dirname $0)
    lc_cmd="${dirname}/live_cycles_amadeus.pl"

    live_cycles=$($lc_cmd)

    for lc in ${live_cycles}; do 
        branch=devl_${lc,,}
        if [[ "$branch" == "$cycle" ]]; then
            return
        fi
    done
    return 1
}

if is_live $branch; then
    echo 'is live'
    exit 0
else
    echo 'not live';
    exit 1
fi
