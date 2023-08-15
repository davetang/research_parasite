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
   | sed 's/ftp:\/\/ftp.sra.ebi.ac.uk\//era-fasp@fasp.sra.ebi.ac.uk:/' \
   | perl -lane '$l = $F[1]; $l =~ s/"//g; print "ascp -QT -l 300m -P33001 -i \${HOME}/asperaweb_id_dsa.openssh $l ."'

exit 0
