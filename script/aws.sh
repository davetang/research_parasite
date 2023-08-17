#!/usr/bin/env bash
#
# Written by Dave Tang
# Year 2023
#
set -euo pipefail

usage(){
>&2 cat << EOF
   Usage

            $ ffs aws (<json> | <stdin>)

   Examples

            Read from a file

            $ ffs aws ffq.json

            Read from STDIN

            $ ffq --aws SRR22891572 | ffs aws -

EOF
exit 1
}

if [[ $# -lt 1 ]]; then
  usage
fi

input=$1
cat ${input} \
   | grep '"url"' \
   | grep '"https' \
   | sed 's/https/s3/' \
   | sed 's/\.s3\.amazonaws\.com//' \
   | perl -lane '
      $l = $F[1];
      $l =~ s/"//g;
      ($f = $l) =~ s/.*\/(.*)$/$1/;
      $l =~ s/\/$f//;
      print "aws s3 sync $l $f --no-sign-request";
   '

exit 0
