#!/bin/bash

LIBS=/usr/lib64/xtables/

# Undocumented options:
LONGOPTS='--closesecret
--contiguous
--hashlimit
--opensecret
--rateest
--rateest-bps
--rateest-pps'

LONGOPTS+='
'$(for M in "${LIBS}"/libipt_[a-z]*.so; do M=${M##*_}; M=${M%.so}; iptables -m $M -h 2>/dev/null | sed -n "/match .*options/,\$p"; done | grep -o -- '--[a-z0-9-]\+')
LONGOPTS+='
'$(for M in "${LIBS}"/libip6t_[a-z]*.so; do M=${M##*_}; M=${M%.so}; ip6tables -m $M -h 2>/dev/null | sed -n "/match .*options/,\$p"; done | grep -o -- '--[a-z0-9-]\+')
LONGOPTS+='
'$(for M in "${LIBS}"/libxt_[a-z]*.so; do M=${M##*_}; M=${M%.so}; iptables -m $M -h 2>/dev/null | sed -n "/match .*options/,\$p"; done | grep -o -- '--[a-z0-9-]\+')

LONGOPTS+='
'=$(for T in "${LIBS}"/libipt_[A-Z]*.so; do T=${T##*_}; T=${T%.so}; iptables -j $T -h 2>/dev/null | sed -n "/target .*options/,\$p"; done | grep -o -- '--[a-z0-9-]\+')
LONGOPTS+='
'=$(for T in "${LIBS}"/libip6t_[A-Z]*.so; do T=${T##*_}; T=${T%.so}; ip6tables -j $T -h 2>/dev/null | sed -n "/target .*options/,\$p"; done | grep -o -- '--[a-z0-9-]\+')
LONGOPTS+='
'=$(for T in "${LIBS}"/libxt_[A-Z]*.so; do T=${T##*_}; T=${T%.so}; iptables -j $T -h 2>/dev/null | sed -n "/target .*options/,\$p"; done | grep -o -- '--[a-z0-9-]\+')

echo "${LONGOPTS}" | tr -d '[]=' | sort -r | uniq | tr '\n' ' ' | fold -s | sed -e 's/^/   \\ /'
echo
