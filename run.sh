#!/usr/bin/env bash

export RCON_PASSWORD=$(openssl rand -base64 10)
export RCON_PORT=25575

tee $HOME/.rcon-cli.yaml <<EOF >/dev/null
host: 127.0.0.1
port: $RCON_PORT
password: $RCON_PASSWORD
EOF

_term() {
  echo "Caught SIGTERM signal!"
  rcon-cli save-all
  rcon-cli stop
}

trap _term SIGTERM

# Start server in background
cat server.properties.default | envsubst > server.properties

./start.sh &

# Start backup process in background
./backup.sh &

# Wait for any process to exit
wait -n

# Exit with status of process that exited first
exit $?