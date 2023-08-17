#!/usr/bin/env bash
#
# Written by Dave Tang
# Year 2023
#
set -euo pipefail

usage(){
>&2 cat << EOF
   Usage

            $ ffs ftp (<json> | <stdin>)

   Examples

            Read from a file

            $ ffs ftp ffq.json

            Read from STDIN

            $ ffq --ftp SRR22891572 | ffs ftp -

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
