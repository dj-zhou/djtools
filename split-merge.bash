#!/bin/bash

# =============================================================================
# split file $1 to many small files, each file is of size <= 10MB
function _dj_split() {
    split -b 10M $1 $2
}

# =============================================================================
function _dj_merge() {
    cat "$1"* > $2
}
