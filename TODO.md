
####TODO

to check the key pressed  -- not finished

install mongodb  -- not finished

setting the wallpaper folder in bashrc  -- not finished
setting ROS source after install the ros  -- not finished
remove dj-zhou-config.bash from tracking  -- not finished


docker
https://phoenixnap.com/kb/how-to-install-docker-on-ubuntu-18-04

sudo apt-get update
sudo apt-get install docker.io

to remove: sudo apt-get remove docker docker-engine docker.io

another tutorial: 
https://www.digitalocean.com/community/tutorials/how-to-install-and-use-docker-on-ubuntu-18-04

####  Cocker Notes

1. docker does not support display (by default)
2. in a docker container, it does not support tab completion (by default)
3. hub.docker.com: djzhou 

#### Docker Commands

1. check if docker is running:
   
   $ 
   
2. check all local images
   $ sudo docker images

3. to remove a local image
   $ sudo docker rmi \<image name\>

4. to search an image with some name
   $ sudo docker search \<image name\>

   for example:

   $ sudo docker search ubuntu

5. to pull an image (from Docker Hub), for example

   $ sudo docker pull ubuntu

6. to list all containers 
   $ sudo docker ps -a 

7. to list the latest image that run
   $ sudo docker ps -l

8. to remove an container that is not needed
   $ sudo docker rm \<CONTAINER ID\> 
   or

   $ sudo docker rm \<NAME\>

9. to rename an container
    $ sudo docker rename \<old name\> \<new name\>

10. to run/stop an container that has been run before

   $ sudo docker start/stop \<CONTAINER ID\>

11. to run a container and then enter it (with bash)

     $ sudo docker start \<CONTAINER ID / name\>

     $ sudo docker attach \<CONTAINER ID / name\> (but no tab completion) (container will stop running)

     or

     $ sudo docker exec -it \<CONTAINER ID / name\> (container will keep running)

12. to commit an container (so to save as an **local** image)

      $ docker commit -m "What you did to the image" -a "Author Name" \<container id\> repository/new_image_name

     `repository` is usually your **Docker Hub** username

13. to check the history of an image:

     $ docker history \<image hash>

14. to push an image to the Docker hub:

     13.1. login:

     $ sudo docker login - u < docker hub user name>

     13.2. tag the image with the registry user name of Docker Hub

     $ sudo docker tag \<repository>/\<new_image_name> \<docker-hub-username>/\<new_image_name>

     13.3. push

     $ sudo docker push \<repository>/\<new_image_name>

     it will take a while to finish pushing

15. copy file from host to a container

     $ sudo docker cp \<path/to/file> \<container id/name>:\<container path>

#### Questions

1. How to have a new commit? How do I know if a container is changed and there is no commit?







