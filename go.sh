#!/bin/bash

for a in {1..1000}
do
  ./gen_test > many_test/test"$a".in
done  
