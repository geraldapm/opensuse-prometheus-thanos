#!/bin/bash
set -e

mkdir -p ../butane-autogen
output_yaml="../butane-autogen/butane-hosts.yaml"
indent="          "

### Edit with list of hosts that will be inserted into /etc/hosts

hostlist=$(cat <<EOF
192.168.100.10 gpmidprome1
192.168.100.20 gpmidprome2
192.168.100.30 gpmidgrafana
192.168.100.40 gpmidthanos

192.168.101.10 gpmsgprome1
192.168.101.20 gpmsgprome2
192.168.101.30 gpmsggrafana
192.168.101.40 gpmsgthanos

192.168.100.201 gpmidservera
192.168.100.202 gpmidserverb
192.168.101.201 gpmsgservera
192.168.101.202 gpmsgserverb
EOF
)

hostlist_parsed=$(echo "$hostlist" | sed "s/^/${indent}/")

# Write the header to the output YAML file
cat > "$output_yaml" <<-EOF
variant: fcos
version: 1.5.0
storage:
  files:
    - path: /etc/hosts
      mode: 0644
      overwrite: true
      contents:
        inline: |
          127.0.0.1 localhost localhost.localdomain
          ::1		localhost localhost.localdomain ipv6-localhost ipv6-loopback

          ###IP_ADDRESS### ###HOSTNAME### ###HOSTNAME###.local ###HOSTNAME###.gpm.my.id
$hostlist_parsed
EOF

echo "/etc/hosts have been generated successfully!"
echo "YAML file '$output_yaml' has been successfully overwritten!"