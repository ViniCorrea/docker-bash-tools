#!/bin/bash
set -e

############################################################
# Help                                                     #
############################################################
Help()
{
   # Display Help
   echo "Monitor a Docker container and watch changes to the image that those container image"
   echo "that those container was originally started from."
   echo "if detect that the image has changed, it will restart the container"
   echo "using the new image."
   echo
   echo "This script is a simplifier version of the watchtower project"
   echo "https://containrrr.dev/watchtower/"
   echo
}

Usage()
{
    # Display usage
    echo
    echo "Syntax: watchtower -i <image> [-t <tag> | -r <registry> | -f | -h]"
    echo
    echo "Arguments:"
    echo "-i <image>     Image name (required)"
    echo "-t <tag>       Tag (default: latest)"
    echo "-r <registry>  Registry and Repository ex: docker.io/containrrr "
    echo "-f             If the container is not running force to start"
    echo "-h             Help"
    echo

}

############################################################
# Process the input options. Add options as needed.        #
############################################################

# Set variables
RUN_IF_STOPPED=false

while getopts i:t:r:fh option; do
    case "${option}" in
        h) #display Help
            Help
            Usage
            exit;;

        i) # Image name
            echo $option
            IMAGE_NAME=${OPTARG}
            echo "IMAGE_NAME: $IMAGE_NAME"
            echo "OPTARG $OPTARG"
            ;;
        r) REGISTRY="${OPTARG}/";;
        f) RUN_IF_STOPPED=true;;
        t) TAG=${OPTARG};;

        \?) # Invalid option
            echo "Invalid option: -${OPTARG}"
            Usage
            exit 2;;
    esac
done

echo "image: $IMAGE_NAME"
if [ -z $IMAGE_NAME ]; then
    echo "-i IMAGE_NAME is required"
    Usage
    exit;
fi

############################################################
# Main program                                             #
############################################################

IMAGE="$REGISTRY$IMAGE_NAME"
CONTAINER_ID=$(docker ps | grep $IMAGE | awk '{print $1}')

docker pull $IMAGE

if [ -z $CONTAINER_ID ] && [ $RUN_IF_STOPPED ];then # Check if the container is running
    echo "container is not running"
    echo "starting container"
    docker-compose up -d $IMAGE_NAME # run the container if is not running
else
    # some time you can have more then one container for the same image but stopped
    for im in $CONTAINER_ID
    do
        CONTAINER_NAME=`docker inspect --format '{{.Name}}' $im | sed "s/\///g"`
        LATEST=`docker inspect --format "{{.Id}}" $IMAGE`
        RUNNING=`docker inspect --format "{{.Image}}" $im`
        echo "Latest:" $LATEST
        echo "Running:" $RUNNING
        if [ "$RUNNING" != "$LATEST" ];then
            echo "upgrading $NAME"
            docker stop $CONTAINER_NAME
            docker rm -f $CONTAINER_NAME # to remove all container with this image
            docker-compose up -d $IMAGE_NAME
        else
            echo "$NAME up to date" # nothing to do
        fi
    done
fi
