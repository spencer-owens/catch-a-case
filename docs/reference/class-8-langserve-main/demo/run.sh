if [ "$1" = "jupyter" ]; then
    docker compose up -d jupyter
elif [ "$1" = "agent" ]; then
    docker compose up -d agent
elif [ "$1" = "chat" ]; then
    docker compose up -d chat
else
    docker compose run --rm main python "$1"
fi
