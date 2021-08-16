# docker-bash-tools
Some bash scripts to make a life easier with docker


## Watchtower

Monitor a Docker container and watch changes to the image that those container image that those container was originally started from using a docker_compose.  

If detect that the image has changed, it will restart the container using the `docker_compose up -d IMAGE`.  

This script is a simplifier version of the watchtower project https://containrrr.dev/watchtower/  

This script need me in the same folder of your docker_compose.

Make a crontab to be more efficent.

You don't use a docker_compose? It's easy to change. Let`s me know if you need some help.
  
### Usage:  
**Syntax**: `watchtower` -i <image> [-t <tag> | -r <registry> | -f | -h]

-i \<image\>     Image name (required)  
-t \<tag\>       Tag (default: latest)  
-r \<registry\>  Registry and Repository ex: docker.io/containrrr  
-f             If the container is not running force to start  
-h             Help  

Crontab Example:   
`*/5 * * * * /bin/bash /home/ubuntu/projects/watchtower.sh -i api -f >> /dev/null`  
To execute the script every 5th minute.
