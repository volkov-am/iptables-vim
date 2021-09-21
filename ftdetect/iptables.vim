" iptables-apply
au BufNewFile,BufRead iptables.up.rules set filetype=iptables
" Debian
au BufNewFile,BufRead rules.v4,rules.v6 set filetype=iptables
" Gentoo
au BufNewFile,BufRead rules-save set filetype=iptables
