#!/bin/bash

File_Run() {

	echo "Would you like to transfer files from the server, or too the server."
	TOO="To the Server"
	FROM="From the Server"
	TRANSFER_SELECTION=$(gum choose "$TOO" "$FROM")
	grep -q "$TOO" <<<"$TRANSFER_SELECTION" && File_Too
	grep -q "$FROM" <<<"$TRANSFER_SELECTION" && File_From
}

File_Too() {
	pkill librewolf
	pkill webcord

	cp -r ~/.librewolf ~/Network/Storage/Transfer/

	rm -rf ~/.config/WebCord/Cache/

	cp -r ~/.config/WebCord ~/Network/Storage/Transfer/

	cp -r ~/.ssh ~/Network/Storage/Transfer/

	cp -r ~/.env ~/Network/Storage/Transfer/
	exit
}

File_From() {
	pkill librewolf
	pkill webcord

	rm -rf ~/.librewolf
	mv ~/Network/Storage/Transfer/.librewolf ~/

	rm -rf ~/.config/WebCord
	mv ~/Network/Storage/Transfer/WebCord ~/.config/

	rm -rf ~/.ssh
	mv ~/Network/Storage/Transfer/.ssh ~/

	rm -rf ~/.env
	mv ~/Network/Storage/Transfer/.env ~/

	gpg --import ~/Network/Storage/Long-Term/stetsed.asc
}

File_Run
