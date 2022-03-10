function create_subnet() {
	#VXLAN (L2VNI)
	ip link add L2VNI${L2VNI} type vxlan id ${L2VNI} local ${VTEP_IPADDR} dstport 4789 nolearning
	ip link set L2VNI${L2VNI} mtu 9000
	ip link set L2VNI${L2VNI} up
	ip -d link show L2VNI${L2VNI}
	
	brctl addbr br${L2VNI}
	brctl stp br${L2VNI} off
	brctl addif br${L2VNI} L2VNI${L2VNI}
	bridge link set dev L2VNI${L2VNI} neigh_suppress on 
	ip addr add dev br${L2VNI} ${GATEWAY}/24
	ip link set br${L2VNI} mtu 9000
	ip link set br${L2VNI} up
	ip link set br${L2VNI} master ${VRF}
	ip route add ${SUBNET} via ${GATEWAY} dev br${L2VNI}
	sysctl -w net.ipv4.conf.br${L2VNI}.arp_accept=1
	sysctl -w net.ipv4.conf.br${L2VNI}.proxy_arp=1
	sysctl -p

	# Check 
	brctl show
	ip -d link show L2VNI${L2VNI}
}


VTEP_IPADDR=172.18.0.2
L2VNI=101001; VRF=vrf-1; SUBNET=10.1.1.0/24; GATEWAY=10.1.1.254; create_subnet
L2VNI=101002; VRF=vrf-1; SUBNET=10.1.2.0/24; GATEWAY=10.1.2.254; create_subnet
L2VNI=102001; VRF=vrf-2; SUBNET=10.2.1.0/24; GATEWAY=10.2.1.254; create_subnet

