#!/bin/bash -e
# vim: set ts=4 sw=4 sts=4 et :
#
# Additional whonix_firewall rules called by reference to this file from
# '/etc/whonix_firewall.d/40_qubes'

source /usr/lib/qubes-whonix/utility_functions.sh

# Start Whonix Firewall
if [ -e /var/run/qubes-service/whonix-gateway ]; then
    ip=$(${QUBESDB}-read ${PREFIX}qubes-netvm-gateway 2> /dev/null)

    export INT_IF="vif+"
    export INT_TIF="vif+"

    iptables -t nat -N PR-QBS-SERVICES
    iptables -A INPUT -i vif+ -p tcp -m tcp --dport 8082 -j ACCEPT
    iptables -A OUTPUT -o vif+ -p tcp -m tcp --sport 8082 -j ACCEPT
    iptables -t nat -A PREROUTING -j PR-QBS-SERVICES
    iptables -t nat -A PR-QBS-SERVICES -d 10.137.255.254/32 -i vif+ -p tcp -m tcp --dport 8082 -j REDIRECT
    iptables -t nat -A OUTPUT -p udp -m owner --uid-owner tinyproxy -m conntrack --ctstate NEW -j DNAT --to ${ip}:53
    iptables -t nat -A OUTPUT -p tcp -m owner --uid-owner tinyproxy -m conntrack --ctstate NEW -j DNAT --to ${ip}:9040

    # Route any traffic FROM netvm TO netvm BACK-TO localhost \\
    # Allows localhost access to tor network \\
    #iptables -t nat -A OUTPUT -s ${ip} -d ${ip} -j DNAT --to-destination 127.0.0.1 \\
fi

if [ -e /var/run/qubes-service/whonix-template ]; then

    # Allow access to qubes update proxy
    iptables -A OUTPUT -o eth0 -p tcp -m tcp --dport 8082 -j ACCEPT
fi
