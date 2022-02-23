#!/bin/bash 

SPINE_NUM=2
LEAF_NUM=2

SET1=$(seq 1 $SPINE_NUM )
SET2=$(seq 1 $LEAF_NUM )


### create docker networks for leaf spine internal connection ###
for i in $SET1
do
  for j in $SET2
  do 
    echo "Create local network for Spine"$i "Leaf"$j
    docker network create "evpn_int_spine"$i"_leaf"$j  --subnet 10.$i"."$j"."0/29
  done 
done 


### create frr routers ### 
for i in $SET1
do
  docker run -dit --name evpn_spine$i --hostname evpn_spine$i --privileged --net "evpn_int_spine"$i"_leaf1" frrouting/frr
  for j in $SET2
  do 
    if !(( $j  == 1 )) 
    then 
      docker network connect "evpn_int_spine"$i"_leaf"$j evpn_spine$i
    fi
  done 
done


for i in $SET2
do
  docker run -dit --name evpn_leaf$i --hostname evpn_leaf$i --privileged --net "evpn_int_spine1_leaf"$i frrouting/frr
  for j in $SET1
  do
    if !(( $j  == 1 ))
    then
      docker network connect "evpn_int_spine"$j"_leaf"$i evpn_leaf$i
    fi
  done
done


#docker network create evpn_net_internal --subnet 10.0.0.0/16
#docker network create 

#docker run -dit --name evpn_spine1 --hostname evpn_spine1 --privileged --net evpn_net_internal --ip 10.0.1.1 frr
#docker run -dit --name evpn_spine2 --hostname evpn_spine2 --privileged --net evpn_net_internal --ip 10.0.1.2 frr

#docker run -dit --name evpn_leaf1 --hostname evpn_leaf1 --privileged --net evpn_net_internal --ip 10.0.0.101 frr
#wqdocker run -dit --name evpn_leaf2 --hostname evpn_leaf2 --privileged --net evpn_net_internal --ip 10.0.0.102 frr




