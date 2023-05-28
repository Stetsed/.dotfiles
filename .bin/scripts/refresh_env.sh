#!/bin/bash

while true; do
	rbw sync
	rbw get Enviroment >~/.env
	sleep 600
done
