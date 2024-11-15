#!/bin/bash -eu

cd $( dirname ${BASH_SOURCE[0]} )

SRC=../../../AwsCryptographicMaterialProviders/runtimes/rust/src/

cp $SRC/concurrent_call.rs src
cp $SRC/dafny_libraries.rs src
# ddb is different, because of ::deps::
cp $SRC/sets.rs src
cp $SRC/time.rs src
cp $SRC/uuid.rs src
