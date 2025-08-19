#!/bin/bash

set -e

export IMAGE=${{ secrets.DOCKER_USERNAME }}/canary:${{github.ref_name}}

sudo sed -i "s|image: arifbudianto/.*|image: ${IMAGE}|" docker-compose.yml

current=$(cat current.txt)

if [ "$current" =  "blue" ]; then
    echo "Pull Image and run green container"
    sudo docker compose pull green
    sudo docker compose up -d --pull always green

    echo "Check healthy Container Green"
    for i in {1..5}; do
    if curl -f http://127.0.0.1:5002/health; then
        echo "Container Green is healthy!"
        break
    else
        echo "Waiting for container Green to be ready..."
        sleep 5
    fi
    done

    echo "Set weight green container to 25%"
    sudo sed 's|server green:5000 down;|server green:5000 weight=25;|' -i nginx/nginx.conf
    sudo docker exec nginx sh -c "sed 's|server green:5000 down;|server green:5000 weight=25;|' /etc/nginx/nginx.conf > /tmp/nginx.conf && cat /tmp/nginx.conf > /etc/nginx/nginx.conf"

    echo "Set weight blue container to 75%"
    sudo sed 's|server blue:5000 weight=100;|server blue:5000 weight=75;|' -i nginx/nginx.conf
    sudo docker exec nginx sh -c "sed 's|server blue:5000 weight=100;|server blue:5000 weight=75;|' /etc/nginx/nginx.conf > /tmp/nginx.conf && cat /tmp/nginx.conf > /etc/nginx/nginx.conf"

    sudo docker exec nginx nginx -s reload

    echo "Check healthy"
    for i in {1..5}; do
    if curl -f http://127.0.0.1:8080/health; then
        echo "Container is healthy!"
        sleep 3
    else
        echo "Waiting for app to be ready..."
        sleep 5
    fi
    done

    echo "Set weight green container to 100%"
    sudo sed 's|server green:5000 weight=25;|server green:5000 weight=100;|' -i nginx/nginx.conf
    sudo docker exec nginx sh -c "sed 's|server green:5000 weight=25;|server green:5000 weight=100;|' /etc/nginx/nginx.conf > /tmp/nginx.conf && cat /tmp/nginx.conf > /etc/nginx/nginx.conf"

    echo "Set weight blue container to 0%"
    sudo sed 's|server blue:5000 weight=75;|server blue:5000 down;|' -i nginx/nginx.conf
    sudo docker exec nginx sh -c "sed 's|server blue:5000 weight=75;|server blue:5000 down;|' /etc/nginx/nginx.conf > /tmp/nginx.conf && cat /tmp/nginx.conf > /etc/nginx/nginx.conf"

    sudo docker exec nginx nginx -s reload

    echo "Check healthy"
    for i in {1..5}; do
    if curl -f http://127.0.0.1:8080/health; then
        echo "Container is healthy!"
        sleep 3
    else
        echo "Waiting for app to be ready..."
        sleep 5
    fi
    done

    echo "Remove blue container"
    sudo docker compose down blue

    current=green
    echo $current > current.txt
              
    echo "green container now running"
else
    echo "Pull Image and run blue container"
    sudo docker compose pull blue
    sudo docker compose up -d --pull always blue

    echo "Check healthy Container blue"
    for i in {1..5}; do
    if curl -f http://127.0.0.1:5001/health; then
        echo "Container blue is healthy!"
        break
    else
        echo "Waiting for container blue to be ready..."
        sleep 5
    fi
    done

    echo "Set weight blue container to 25%"
    sudo sed 's|server blue:5000 down;|server blue:5000 weight=25;|' -i nginx/nginx.conf
    sudo docker exec nginx sh -c "sed 's|server blue:5000 down;|server blue:5000 weight=25;|' /etc/nginx/nginx.conf > /tmp/nginx.conf && cat /tmp/nginx.conf > /etc/nginx/nginx.conf"

    echo "Set weight green container to 75%"
    sudo sed 's|server green:5000 weight=100;|server green:5000 weight=75;|' -i nginx/nginx.conf
    sudo docker exec nginx sh -c "sed 's|server green:5000 weight=100;|server green:5000 weight=75;|' /etc/nginx/nginx.conf > /tmp/nginx.conf && cat /tmp/nginx.conf > /etc/nginx/nginx.conf"

    sudo docker exec nginx nginx -s reload

    echo "Check healthy"
    for i in {1..5}; do
    if curl -f http://127.0.0.1:8080/health; then
        echo "Container is healthy!"
        sleep 3
    else
        echo "Waiting for app to be ready..."
        sleep 5
    fi
    done

    echo "Set weight blue container to 100%"
    sudo sed 's|server blue:5000 weight=25;|server blue:5000 weight=100;|' -i nginx/nginx.conf
    sudo docker exec nginx sh -c "sed 's|server blue:5000 weight=25;|server blue:5000 weight=100;|' /etc/nginx/nginx.conf > /tmp/nginx.conf && cat /tmp/nginx.conf > /etc/nginx/nginx.conf"

    echo "Set weight green container to 0%"
    sudo sed 's|server green:5000 weight=75;|server green:5000 down;|' -i nginx/nginx.conf
    sudo docker exec nginx sh -c "sed 's|server green:5000 weight=75;|server green:5000 down;|' /etc/nginx/nginx.conf > /tmp/nginx.conf && cat /tmp/nginx.conf > /etc/nginx/nginx.conf"

    sudo docker exec nginx nginx -s reload

    echo "Check healthy"
    for i in {1..5}; do
    if curl -f http://127.0.0.1:8080/health; then
        echo "Container is healthy!"
        sleep 3
    else
        echo "Waiting for app to be ready..."
        sleep 5
    fi
    done

    echo "Remove green container"
    sudo docker compose down green

    current=blue
    echo $current > current.txt
              
    echo "blue container now running"
fi

echo "done"


    