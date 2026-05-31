#!/bin/sh

#Execute on all swarm managers
#Allow Docker ports in firewalld

# Allow Swarm cluster management (2377)
sudo firewall-cmd --zone=public --add-port=2377/tcp --permanent

# Node discovery & control plane (7946 TCP/UDP)
sudo firewall-cmd --zone=public --add-port=7946/tcp --permanent
sudo firewall-cmd --zone=public --add-port=7946/udp --permanent

# Overlay network (VXLAN) (4789 UDP)
sudo firewall-cmd --zone=public --add-port=4789/udp --permanent

sudo firewall-cmd --reload
