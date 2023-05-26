#!/bin/bash

current_time=$(date +%H%M)

if [[ "$current_time" > "0700" ]] && [[ "$current_time" < "2000" ]]; then
	ectool fwchargelimit 100
else
	ectool fwchargelimit 80
fi

exit
