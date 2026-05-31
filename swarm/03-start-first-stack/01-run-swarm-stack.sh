# have to allow scheduling visualizer on manger node (we set to not allow in demo 02)
# To allow scheduling again:
docker node update --availability active $MANGER_ID

docker stack deploy -c docker-stack.yml mydemo

#Open up browser to see visualizer

#lists all services
docker stack ls

#lsist only services fot stack specified
docker stack services mydemo

#On which nodes are the services running? 
#Note: The IDs are the task id.
docker stack ps mydemo

#Or by specific service name to see tasks
docker service ps mydemo_visualizer

docker service logs mydemo_web_app

#View task info, like  which container associated
docker inspect <TASK_ID>
#Can also look at container name, it will have included in it the task id!
docker ps

#scale the web server service (keep on eye on browser to see visualizer update!)
docker service scale mydemo_web_app=10
docker stack services mydemo

docker stack rm mydemo
docker stack ls
docker service ls

#do a rollowing update via cli (go see visualizer to see what happens)
docker service update \
  --update-order start-first \
  --update-parallelism 1 \
  --update-delay 10s \
  --image nginx:alpine \
  mydemo_web_app

  #can also follow along on cli (only suppots immediate rollback. cannot rollback 2 version back etc ...)
  watch docker service ps mydemo_web_app

  #if you want to rollback to specif image, then need to specify it
  # docker service update \
  #--image myapp:1.0 \
  #mydemo_web_app

  # !!! ROLLBAK via cli
  docker service rollback mydemo_web_app

# if want to do via stack file , have to create a new version of stack file with ...
docker stack deploy -c docker-stack.yml mydemo


services:
  web_app:
    image: nginx:latest

    deploy:
      replicas: 3

      placement:
        constraints:
          - node.role == worker

      update_config:
        parallelism: 1
        delay: 10s
        order: start-first

      rollback_config:
        parallelism: 1
        delay: 5s

    ports:
      - "80:80"

    networks:
      - app_overlay


  
#cleanup
docker swarm leave --force
# deletes EVERYTHING!
docker system prune -a --volumes
docker info | grep -i swarm
