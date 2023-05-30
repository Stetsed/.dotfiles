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
	gum spin -s dot --title "Copying Librewolf Files..." -- cp -r ~/.librewolf ~/Network/Storage/Transfer/

	rm -rf ~/.config/WebCord/Cache/
	pkill webcord
	gum spin -s dot --title "Copying WebCord Files..." -- cp -r ~/.config/WebCord ~/Network/Storage/Transfer/

	gum spin -s dot --title "Copying SSH Files..." -- cp -r ~/.ssh ~/Network/Storage/Transfer/

	gum spin -s dot --title "Copying .env file..." -- cp -r ~/.env ~/Network/Storage/Transfer/
	exit
}

File_From() {
	pkill librewolf
	rm -rf ~/.librewolf
	gum spin -s dot --title "Moving Librewolf Files..." -- mv ~/Network/Storage/Transfer/.librewolf ~/

	pkill webcord
	rm -rf ~/.config/WebCord
	um spin -s dot --title "Moving WebCord Files..." -- mv ~/Network/Storage/Transfer/WebCord ~/.config/

	rm -rf ~/.ssh
	um spin -s dot --title "Moving SSH Files..." -- mv ~/Network/Storage/Transfer/.ssh ~/

	rm -rf ~/.env
	um spin -s dot --title "Moving .env file..." -- mv ~/Network/Storage/Transfer/.env ~/

	gpg --import ~/Network/Storage/Long-Term/stetsed.asc
}

File_Run
