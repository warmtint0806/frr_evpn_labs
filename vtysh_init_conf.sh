#!bin/bash 

SPINE_NUM=2
LEAF_NUM=2

SET1=$(seq 1 $SPINE_NUM )
SET2=$(seq 1 $LEAF_NUM )

VTYSH_CONF_TEXT="service integrated-vtysh-config"

for i in $SET1
do
  docker exec -it "evpn_spine"$i /bin/sh -c "echo $VTYSH_CONF_TEXT >> /etc/frr/vtysh.conf"
done

for j in $SET2
do 
  docker exec -it "evpn_leaf"$j /bin/sh -c "echo $VTYSH_CONF_TEXT >> /etc/frr/vtysh.conf"
done
