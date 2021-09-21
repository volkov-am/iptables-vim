"============================================================================
"
" iptables-save/restore syntax highlighter
"
" Language:	   iptables-save/restore file
" Version:     1.10
" Date:        2021-09-21
" Maintainer:  Eric Haarbauer <ehaar70{AT}gmail{DOT}com>
" License:     This file is placed in the public domain.
"
"============================================================================
" Section:  Notes  {{{1
"============================================================================
"
" This vim syntax script highlights files used by Harald Welte's iptables-save
" and iptables-restore utilities.  Both utilities are part of the iptables
" application (http://www.netfilter.org/projects/iptables).
" 
" Features:
"
"   * Distinguishes commands, options, modules, targets and chains.
"   * Distinguishes numeric IP addresses from net masks.
"   * Highlights tokens that occur only in hand-edited files; for example,
"     "--append" and "destination-unreachable".
"   * Special handling for module names; for example, the tcp module is
"     colored differently from the tcp protocol.
"
" Options:
"
"   Customize the behavior of this script by setting values for the following
"   options in your .vimrc file.  (Type ":h vimrc" in vim for more information
"   on the .vimrc file.)
"
"   g:Iptables_SpecialDelimiters
"     This variable, if set to a non-zero value, distinguishes numeric
"     delimiters, including the dots in IP addresses, the slash that separates
"     an IP address from a netmask, and the colon that separates the ends of a
"     port range.  If not set, this option defaults to off.
"
" Known Issues:
"
"   * Some special argument tokens are highlighted whether or not they are
"     used with the correct option.  For example, "destination-unreachable"
"     gets special highlighting whether or not is used as an argument to the
"     --icmp-type option.  In practice, this is rarely a problem.
"
" Reporting Issues:
"
"   If you discover an iptables file that this script highlights incorrectly,
"   please email the author (address at the top of the script) with the
"   following information:
"
"     * Problem iptables file WITH ANY SENSITIVE INFORMATION REMOVED
"     * The release version of this script (see top of the script)
"     * If possible, a patch to fix the problem
"
" Design Notes:
"
"   Part of this script is autogenerated from the output of the iptables man
"   page.  The source code for generating the script is available from the
"   author on request (see email address at the top of the script).  The
"   script should build from source on most Linux systems with iptables
"   installed.
"
"   The build system that generates this script strips special CVS tokens
"   (like "Id:") so that CVS no longer recognizes them.  This allows users to
"   place the script in their own version control system without losing
"   information.  The author encourages other vim script developers to adopt a
"   similar approach in their own scripts.
"
" Installation:
"
"   Put this file in your user runtime syntax directory, usually ~/.vim/syntax
"   in *NIX or C:\Program Files\vim\vimfiles\syntax in Windows.  Type ":h
"   syn-files" from within vim for more information.
"
"   The iptables-save and iptables-restore applications do not specify a
"   naming standard for the files they use.  However, iptables-save places a
"   comment in the first line of its output.  Other applications, such as
"   Fedora's system-config-securitylevel uses the iptables-save/restore
"   format, but with a different leading comment.  We can use these leading
"   comments to identify the filetype by placing the following code in the
"   scripts.vim file in your user runtime directory:
"   
"      if getline(1) =~ "^# Generated by iptables-save" ||
"       \ getline(1) =~ "^# Firewall configuration written by"
"          setfiletype iptables
"          set commentstring=#%s
"          finish
"      endif
"
"   Setting the commentstring on line 4 allows Meikel Brandmeyer's
"   EnhancedCommentify script (vimscript #23) to work with iptables files.
"   (Advanced users may want to set the commentstring option in an ftplugin
"   file or in autocommands defined in .vimrc.)
"
"============================================================================
" Source File: Id: iptables.src.vim 43 2014-06-08 03:21:32Z ehaar 
"============================================================================
" Section:  Initialization  {{{1
"============================================================================

" For version 5.x: Clear all syntax items
" For version 6.x: Quit when a syntax file was already loaded
if !exists("main_syntax")
  if version < 600
    syntax clear
  elseif exists("b:current_syntax")
    finish
  endif
  let main_syntax = 'iptables'
endif

" Don't use standard HiLink, it will not work with included syntax files
if version < 508
  command! -nargs=+ IptablesHiLink highlight link <args>
else
  command! -nargs=+ IptablesHiLink highlight default link <args>
endif

syntax case match

if version < 600
    set iskeyword+=-
else
    setlocal iskeyword+=-
endif

" Initialize global public variables:  {{{2

" Support deprecated variable name used prior to release 1.07.
if exists("g:iptablesSpecialDelimiters") &&
\ !exists("g:Iptables_SpecialDelimiters")

    let   g:Iptables_SpecialDelimiters = g:iptablesSpecialDelimiters
    unlet g:iptablesSpecialDelimiters
    " echohl WarningMsg | echo "Warning:" | echohl None
    " echo "The g:iptablesSpecialDelimiters variable is deprecated."
    " echo "Please use g:Iptables_SpecialDelimiters in your .vimrc instead"

endif

if exists("g:Iptables_SpecialDelimiters")
    let s:Iptables_SpecialDelimiters = g:Iptables_SpecialDelimiters
else
    let s:Iptables_SpecialDelimiters = 0
endif

"============================================================================
" Section:  Group Definitions  {{{1
"============================================================================

syntax keyword iptablesSaveDirective COMMIT
syntax match   iptablesSaveOperation "^[:*]"

syntax keyword iptablesTable filter nat mangle raw security

syntax keyword iptablesTarget
    \ ACCEPT DROP RETURN
    \ ACCOUNT AUDIT CHAOS CHECKSUM CLASSIFY CLUSTERIP CONNMARK CONNSECMARK CT DELUDE
    \ DHCPMAC DNAT DNETMAP DNPT DSCP ECHO ECN HL HMARK IDLETIMER IPMARK LED LOG
    \ LOGMARK MARK MASQUERADE NETMAP NFLOG NFQUEUE NOTRACK PROTO RATEEST REDIRECT
    \ REJECT SECMARK SET SNAT SNPT SYNPROXY SYSRQ TARPIT TCPMSS TCPOPTSTRIP TEE TOS
    \ TPROXY TRACE TTL ULOG

syntax keyword iptablesBuiltinChain
    \ INPUT OUTPUT FORWARD PREROUTING POSTROUTING

syntax keyword iptablesCommand -A -D -I -R -L -F -Z -N -X -P -E
    \ --append --delete --insert --replace --list --flush --zero
    \ --new-chain --delete-chain --policy --rename-chain

syntax keyword iptablesParam   -p -s -d -j -i -o -f -c -t

syntax match iptablesOperator "\s\zs!\ze\s"

syntax keyword iptablesModuleName contained
    \ addrtype ah bpf cgroup cluster comment condition connbytes connlabel connlimit
    \ connmark conntrack cpu dccp devgroup dhcpmac dscp dst ecn esp eui64 frag fuzzy
    \ geoip gradm hashlimit hbh helper hl icmp icmp6 iface ipp2p iprange ipv4options
    \ ipv6header ipvs length length2 limit lscan mac mark mh multiport nfacct osf
    \ owner physdev pknock pkttype policy psd quota quota2 rateest realm recent
    \ rpfilter rt sctp set socket state statistic string tcp tcpmss time tos ttl u32
    \ udp

syntax keyword iptablesModuleType
    \ UNSPEC UNICAST LOCAL BROADCAST ANYCAST MULTICAST BLACKHOLE UNREACHABLE
    \ PROHIBIT THROW NAT XRESOLVE INVALID ESTABLISHED NEW RELATED SYN ACK FIN
    \ RST URG PSH ALL NONE

" From --reject-with option
syntax keyword iptablesModuleType
    \ icmp-net-unreachable net-unreach
    \ icmp-host-unreachable host-unreach
    \ icmp-port-unreachable port-unreach
    \ icmp-proto-unreachable proto-unreach
    \ icmp-net-prohibited net-prohib
    \ icmp-host-prohibited host-prohib
    \ icmp-admin-prohibited admin-prohib
    \ tcp-reset tcp-rst
    \ icmp6-no-route no-route
    \ icmp6-adm-prohibited adm-prohibited
    \ icmp6-addr-unreachable addr-unreach
    \ icmp6-port-unreachable
    \ policy-fail
    \ reject-route

" From --icmp-type option
syntax keyword iptablesModuleType
    \ any
    \ echo-reply pong
    \ destination-unreachable
    \    network-unreachable
    \    host-unreachable
    \    protocol-unreachable
    \    port-unreachable
    \    fragmentation-needed
    \    source-route-failed
    \    network-unknown
    \    host-unknown
    \    network-prohibited
    \    host-prohibited
    \    TOS-network-unreachable
    \    TOS-host-unreachable
    \    communication-prohibited
    \    host-precedence-violation
    \    precedence-cutoff
    \ source-quench
    \ redirect
    \    network-redirect
    \    host-redirect
    \    TOS-network-redirect
    \    TOS-host-redirect
    \ echo-request ping
    \ router-advertisement
    \ router-solicitation
    \ time-exceeded
    \    ttl-zero-during-transit
    \    ttl-zero-during-reassembly
    \ parameter-problem
    \    ip-header-bad
    \    required-option-missing
    \ timestamp-request
    \ timestamp-reply
    \ address-mask-request
    \ address-mask-reply

" If we used a keyword for this, port names would be colored the same
" as modules with the same name (e.g. tcp, udp, icmp).
syntax keyword iptablesParam -m --match skipwhite nextgroup=iptablesModuleName

syntax region iptablesString start=+"+ skip=+\\"+ end=+"+ oneline

syntax match  iptablesComment    "^#.*" contains=iptablesTodo
syntax match  iptablesBadComment "^\s\+\zs#.*" " Pound must be in first column

syntax keyword iptablesTodo contained TODO FIXME XXX NOT NOTE

" Special Delimiters: {{{2

if s:Iptables_SpecialDelimiters != 0
    syntax match iptablesNumber    "\<[0-9./:]\+\>"
        \ contains=iptablesMask,iptablesDelimiter
    syntax match iptablesDelimiter "[./:]"     contained
    syntax match iptablesMask      "/[0-9.]\+" contained 
        \ contains=iptablesDelimiter
else " s:Iptables_SpecialDelimiters == 0
    syntax match iptablesNumber    "\<[0-9./]\+\>"
        \ contains=iptablesMask,iptablesDelimiter
    syntax match iptablesDelimiter "/"         contained
    syntax match iptablesMask      "/[0-9.]\+" contained 
        \ contains=iptablesDelimiter
endif

"============================================================================
" Section:  Autogenerated Groups  {{{2
"============================================================================

" Begin autogenerated section.
" iptables2vim-longs.sh:      "20210921"
" iptables:                   "iptables v1.8.7"

syntax keyword iptablesLongParam
   \ --zone-reply --zone-orig --zone --zero --xor-tos --xor-mark --xdcc --wscale
   \ --winmx --weekdays --waste --wait-interval --wait --vproto --vportctl --vport
   \ --vmethod --version --verbose --vdir --validmark --vaddr --upper-limit
   \ --update-subcounters --update-counters --update --up --ulog-qthreshold
   \ --ulog-prefix --ulog-nlgroup --ulog-cprange --uid-owner --u32 --type
   \ --tunnel-src --tunnel-dst --ttl-set --ttl-lt --ttl-inc --ttl-gt --ttl-eq
   \ --ttl-dec --ttl --transparent --tproxy-mark --total-nodes --to-source --tos
   \ --to-ports --to-destination --to --tname --timestop --timestart --timestamp
   \ --timeout --time --tcp-option --tcp-flags --tarpit --table --synscan --syn
   \ --suppl-groups --strip-options --string --strict --stealth --static --state
   \ --srh-tag --srh-segs-left-lt --srh-segs-left-gt --srh-segs-left-eq --srh-psid
   \ --srh-nsid --srh-next-hdr --srh-lsid --srh-last-entry-lt --srh-last-entry-gt
   \ --srh-last-entry-eq --srh-hdr-len-lt --srh-hdr-len-gt --srh-hdr-len-eq
   \ --src-type --src-range --src-pfx --src-group --src-cc --sports --sport --spi
   \ --source-ports --source-port --source-country --source --soul --soft
   \ --socket-exists --shift --set-xmark --set-tos --set-mss --set-mark --set-mac
   \ --set-dscp-class --set-dscp --set-counters --set-class --set --selctx --seconds
   \ --save-mark --save --sack-perm --running --rt-type --rttl --rt-segsleft
   \ --rt-len --rt-0-res --rt-0-not-strict --rt-0-addrs --rsource --right-shift-mark
   \ --reuse --return-nomatch --restore-skmark --restore-mark --restore --reset
   \ --reqid --replace --rename-chain --remove --reject-with --reap --realm --rdest
   \ --rcheck --rateest-pps2 --rateest-pps1 --rateest-pps --rateest-name
   \ --rateest-lt --rateest-interval --rateest-gt --rateest-ewmalog --rateest-eq
   \ --rateest-delta --rateest-bps2 --rateest-bps1 --rateest-bps --rateest2
   \ --rateest1 --rateest --random-fully --random --quota --queue-num
   \ --queue-cpu-fanout --queue-bypass --queue-balance --psd-weight-threshold
   \ --psd-lo-ports-weight --psd-hi-ports-weight --psd-delay-threshold --proto-set
   \ --protocol --proto --promisc --probability --prefix --ports --policy --pol
   \ --pointtopoint --pointopoint --pkt-type --physdev-out --physdev-is-out
   \ --physdev-is-in --physdev-is-bridged --physdev-in --persistent --path
   \ --packets-lt --packets-gt --packets-eq --packets --packet --out-interface
   \ --or-tos --or-mask --or-mark --opensecret --on-port --on-ip --oif
   \ --object-pinned --numeric --nowildcard --notrack --no-change --noarp --nfmask
   \ --nflog-threshold --nflog-size --nflog-range --nflog-prefix --nflog-group
   \ --nfacct-name --next --new --name --mute --multicast --mss --monthdays
   \ --modprobe --mode --mirai --mh-type --match-set --match --mask --mark --map-set
   \ --map-queue --map-prio --map-mark --mac-source --mac --lower-up --lower-limit
   \ --loose --loopback --log-uid --log-tcp-sequence --log-tcp-options --log-prefix
   \ --log-macdecode --log-level --log-ip-options --log --local-node --list-rules
   \ --list --line-numbers --limit-iface-out --limit-iface-in --limit-burst --limit
   \ --length --left-shift-mark --led-trigger-id --led-delay --led-always-blink
   \ --layer7 --layer5 --layer4 --layer3 --label --knockports --kerneltz --kazaa
   \ --jump --ipvs --ipv6 --ipv4 --ipcompspi --invert --insert --in-interface
   \ --iface --icmpv6-type --icmp-type --icase --honeypot --hmark-tuple
   \ --hmark-src-prefix --hmark-sport-mask --hmark-sport --hmark-spi-mask
   \ --hmark-spi --hmark-rnd --hmark-proto-mask --hmark-offset --hmark-mod
   \ --hmark-dst-prefix --hmark-dport-mask --hmark-dport --hl-set --hl-lt --hl-inc
   \ --hl-gt --hl-eq --hl-dec --hitcount --hex-string --helper --header --hbh-opts
   \ --hbh-len --hashmode --hashlimit-upto --hashlimit-srcmask
   \ --hashlimit-rate-match --hashlimit-rate-interval --hashlimit-name
   \ --hashlimit-mode --hashlimit-htable-size --hashlimit-htable-max
   \ --hashlimit-htable-gcinterval --hashlimit-htable-expire --hashlimit-dstmask
   \ --hashlimit-burst --hashlimit-above --hashlimit --hash-init --grscan --grow
   \ --goto --gnu --gid-owner --genre --gateway --from --fragres --fragmore
   \ --fragment --fraglen --fraglast --fragid --fragfirst --flush --flags
   \ --expevents --exist --exact --every --espspi --enabled --edk --ecn-tcp-remove
   \ --ecn-tcp-ece --ecn-tcp-cwr --ecn-ip-ect --ecn --dynamic --dst-type --dst-range
   \ --dst-pfx --dst-opts --dst-len --dst-group --dst-cc --dscp-class --dscp
   \ --dports --dport --down --dormant --disabled --dir --dev-out --dev-in
   \ --destination-ports --destination-port --destination-country --destination
   \ --delude --del-set --delete-chain --delete --dccp-types --dccp-option --dc
   \ --datestop --datestart --ctstatus --ctstate --ctreplsrcport --ctreplsrc
   \ --ctrepldstport --ctrepldst --ctproto --ctorigsrcport --ctorigsrc
   \ --ctorigdstport --ctorigdst --ctmask --ctexpire --ctevents --ctdir --cpu
   \ --contiguous --connlimit-upto --connlimit-saddr --connlimit-mask
   \ --connlimit-daddr --connlimit-above --connbytes-mode --connbytes-dir
   \ --connbytes --condition --comment --cnscan --cluster-total-nodes --clustermac
   \ --cluster-local-nodemask --cluster-local-node --cluster-hash-seed --closesecret
   \ --clamp-mss-to-pmtu --chunk-types --checksum-fill --checkip --check --cgroup
   \ --bytes-lt --bytes-gt --bytes-eq --bytecode --broadcast --bit --autoclose --arp
   \ --ares --apple --append --any --and-tos --and-mask --and-mark --algo --alarm
   \ --ahspi --ahres --ahlen --add-set --addr --accept-local

" End autogenerated section.

"============================================================================
" Section:  Group Linking  {{{1
"============================================================================

IptablesHiLink iptablesSaveDirective PreProc
IptablesHiLink iptablesSaveOperation PreProc

IptablesHiLink iptablesTable         Statement
IptablesHiLink iptablesTarget        Statement
IptablesHiLink iptablesBuiltinChain  Type

IptablesHiLink iptablesCommand       Operator

IptablesHiLink iptablesModuleName    Type
IptablesHiLink iptablesModuleType    Type

IptablesHiLink iptablesOperator      Operator
IptablesHiLink iptablesParam         Identifier
IptablesHiLink iptablesLongParam     Identifier

IptablesHiLink iptablesNumber        Constant

if s:Iptables_SpecialDelimiters != 0
    IptablesHiLink iptablesMask      PreProc
    IptablesHiLink iptablesDelimiter Delimiter
else " s:Iptables_SpecialDelimiters == 0 
    IptablesHiLink iptablesMask      Special
    IptablesHiLink iptablesDelimiter None
endif

IptablesHiLink iptablesString        Constant

IptablesHiLink iptablesComment       Comment
IptablesHiLink iptablesBadComment    Error
IptablesHiLink iptablesTodo          Todo   

"============================================================================
" Section:  Clean Up    {{{1
"============================================================================

delcommand IptablesHiLink

let b:current_syntax = "iptables"

if main_syntax == 'iptables'
  unlet main_syntax
endif

" Autoconfigure vim indentation settings
" vim:ts=4:sw=4:sts=4:fdm=marker:iskeyword+=-
