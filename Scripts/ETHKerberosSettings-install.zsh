#!/bin/zsh
# shellcheck shell=bash

file_path='/etc/krb5.conf'

cat > "$file_path" <<'EOF'
[libdefaults]
default_realm = D.ETHZ.CH
forwardable = true
proxiable = true
renewable = true
kdc_timeout = 3
renew_lifetime = 7d
ticket_lifetime = 1h

[realms]
D.ETHZ.CH = {
kdc = d.ethz.ch
admin_server = d.ethz.ch
default_domain = d.ethz.ch
}

[domain_realm]
.d.ethz.ch = D.ETHZ.CH
d.ethz.ch = D.ETHZ.CH
.ethz.ch = D.ETHZ.CH
ethz.ch = D.ETHZ.CH
EOF

/usr/sbin/chown root:wheel "$file_path"
/bin/chmod 644 "$file_path"