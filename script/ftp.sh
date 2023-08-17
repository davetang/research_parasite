#!/usr/bin/env bash
#
# Written by Dave Tang
# Year 2023
#
set -euo pipefail

usage(){
>&2 cat << EOF
   Usage

            $ $0 (<json> | <stdin>)

   Examples

            Read from a file

            $ $0 ffq.json

            Read from STDIN

            $ ffq --ftp SRR22891572 | $0 -

EOF
exit 1
}


if [[ $# -lt 1 ]]; then
  usage
fi

input=$1
cat ${input} \
   | grep '"url"' \
   | perl -lane '
      $l = $F[1];
      $l =~ s/"//g;
      ($f = $l) =~ s/.*\/(.*)$/$1/;
      print "if [[ ! -f $f ]]; then";
      print "   wget -c $l";
      print "fi";
   '

exit 0
