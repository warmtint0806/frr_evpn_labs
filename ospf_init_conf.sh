#!bin/bash 

SPINE_NUM=2
LEAF_NUM=2

SET1=$(seq 1 $SPINE_NUM )
SET2=$(seq 1 $LEAF_NUM )

for i in $SET1
do
  docker exec -it "evpn_spine"$i /bin/sh -c "sed -i 's/ospfd=no/ospfd=yes/g' /etc/frr/daemons"
done

for j in $SET2
do 
  docker exec -it "evpn_leaf"$j /bin/sh -c "sed -i 's/ospfd=no/ospfd=yes/g' /etc/frr/daemons"
done
