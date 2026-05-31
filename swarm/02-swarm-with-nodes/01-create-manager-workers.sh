#!/bin/sh

#If you forget and want to see interface that swarm advertises address on
docker info

#To start over and remove swarm (ensure no services running)
#This will remove overlay ingress network too.
docker swarm leave --force

#Verifyu its gone (Swarm: inactive)
docker info | grep Swarm


#Start over (Swarm: active)..
#default will use private IP of EC2 but can choose other if have many IPs (NICs) via  --advertise-addr x.x.x.x
docker swarm init

#ssh into another EC2 instance that will be a worker
#Token will be different than the one below ..
#Ensure ec2 instance has docker installed and that Docker-SG used to allow TCP/2377, TCP/UDP/7946, UDP/4789
# But this is not even enough since O.S firewal will DROP all which can see
#with command "sudo iptables -L -n" ...
#Output ...
#  Chain DOCKER (2 references)
#  target     prot opt source               destination
#  DROP       all  --  0.0.0.0/0            0.0.0.0/0
#  DROP       all  --  0.0.0.0/0            0.0.0.0/0
#To fix must add firewal rules as per ec2-firewall-commands.sh


docker swarm join --token SWMTKN-1-3tx1ie5cafgid8yrhjpnwzgrc3xcy1as8xxq7auqmngb9cbucu-bj5ym5rbixfqabmpyao4hwsfk 172.31.36.186:2377

#Forgot joint token? Here is how to get them back ..
docker swarm join-token worker
docker swarm join-token manager


#perform on worker and will see swarm is active
docker info

#on manager
docker node ls

docker node inspect $NODE_ID

docker service create --name nginx-demo --replicas 3 -p 8080:80 nginx:latest

docker service ls

# List tasks
docker service ps nginx-demo

# Inspect running containers
docker ps

# Scale a service
docker service scale nginx-demo=10

# Remove a service
docker service rm nginx-demo


#If you want to only schedule on manager nodes then 
# Drain the manger nodes from already running container (if the case) and re-schedule on another worker node
docker node update --availability drain <manager-node-name>

# Will now see drain (Now Swarm will not schedule tasks on the manager.)
docker node ls

# To allow scheduling again:
docker node update --availability active manager1

docker service scale nginx-demo=10

#confirm all on worker nodes
docker service ps nginx-demo

# Now goto manager node publicIP:8080 and will still se nginx homepage even though not running on manager note, 
# The routing mesh has routed the request to worker node

docker service scale nginx-demo=0
# nor goto browser,  does not work anymore

#2. Add a second worker node! best to use a EC2 launch template with Docker SG (manually pick another AZ/subnet)
# !!! addd "docker swarm joing --token ... to ec2 user-data script !!! and it will auto joing swarm
# On Manger execute ..
#Forgot joint token? Here is how to get them back ..
docker swarm join-token worker
#Goto worker and (added to ec2 user-data script to auto joing swarm
#docker swarm join --token SWMTKN-1-3tx1ie5cafgid8yrhjpnwzgrc3xcy1as8xxq7auqmngb9cbucu-bj5ym5rbixfqabmpyao4hwsfk 172.31.36.186:2377

#start over
docker service rm  nginx-demo

docker service scale nginx-demo=10

#should be split 5 each on 2 woker nodes
docker service create --name nginx-demo --replicas 10 -p 8080:80 nginx:latest
docker service ps nginx-demo

#can see on each node by using filter (by using id or hostname)
docker service ps nginx-demo --filter node=jazk6wwqp8hlr09g611jfm8bj

# 3. scale to 0, remove reservice and re-publish on port 80 only for 2 replicas, we will connect workers
# to AWS ALB via TG (will use Instance Type) but mention could also use a ASG to scale node horizaontal (HPA)
docker service scale nginx-demo=0
docker service rm  nginx-demo
# !!!!! go create AWS ALB/TG and point to worker nodes

#now that alb and TG are pointing to both docker workers ...
docker service create --name nginx-demo --replicas 2 -p 80:80 nginx:latest
docker service ps nginx-demo

# paste your ALB DNS and you will see nginx homepage
# Will still see it
docker service scale nginx-demo=1

#Now, ALB nothing (timeout)
docker service scale nginx-demo=0

#Now, backup
docker service scale nginx-demo=2


Lab: Setup your first swarm cluster on AWS EC2
1) Ensure docker installed
2) AWS EC2 SG 
3) EC2 Firewall on manager
4) swarm init
5) swarm join
6) docker node ls
