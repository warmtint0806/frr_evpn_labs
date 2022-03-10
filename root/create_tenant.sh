#-------------------------------------------------------
# Underlay IF MTU (+50 due to VXLAN overhead) 
#-------------------------------------------------------

NIC=eth0
ip link set $NIC mtu 9100
VTEP_IPADDR=172.18.0.2
echo $VTEP_IPADDR

#-------------------------------------------------------
# Tenant
#-------------------------------------------------------
function create_tenant() {
    # VRF
    ip link add ${VRF} type vrf table ${VRF_TABLE_ID}
    ip link set dev ${VRF} up
    ip link set ${NIC}.${VLAN} master ${VRF}
    ip route add table ${VRF_TABLE_ID} unreachable default metric 4278198272 # 蓋
    sysctl -w net.ipv4.conf.${VRF}.rp_filter=0
    sysctl -p

    # Check
    ip vrf show
    ip link show type vrf
    ip route show vrf ${VRF}
    ip -d link show ${VRF}

    # VXLAN (L3VNI)
    ip link add L3VNI${L3VNI} type vxlan id ${L3VNI} local ${VTEP_IPADDR} dstport 4789 nolearning
    ip link set L3VNI${L3VNI} mtu 9000
    ip link set L3VNI${L3VNI} up
    ip -d link show L3VNI${L3VNI}

    # Bridge
    brctl addbr br${L3VNI}
    brctl stp br${L3VNI} off
    brctl addif br${L3VNI} L3VNI${L3VNI}
    bridge link set dev L3VNI${L3VNI} neigh_suppress on
    ip link set br${L3VNI} mtu 9000
    ip link set br${L3VNI} up
    ip link set br${L3VNI} master ${VRF}
    sysctl -p

    # Check
    brctl show
    ip -d link show L3VNI${L3VNI}
    vtysh -c "show interface L3VNI${L3VNI}"
    ip addr show vrf ${VRF}
}

L3VNI=101000 ; VRF=vrf-1 ; VLAN=3001 ; VRF_TABLE_ID=101000 ; create_tenant
L3VNI=102000 ; VRF=vrf-2 ; VLAN=3002 ; VRF_TABLE_ID=102000 ; create_tenant
