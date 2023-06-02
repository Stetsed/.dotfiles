#!/bin/bash

Extra_Run() {
	SERVER_SETUP="Server Setup"
	ZFS_REMOTE_UNLOCK="ZFS Remote Unlock Setup"
	FRAMEWORK_TLP="Framework TLP Setup"
	FRAMEWORK_80_100="Framework 80/100 Power Setup"
	FRAMEWORK_FINGERPRINT="Framework Fingerprint Setup"
	TRANSFER_FILES="Transfer Files"
  SUNSHINE_SETUP="Setup Sunshine"
	SELECTION=$(gum choose "$SERVER_SETUP" "$ZFS_REMOTE_UNLOCK" "$FRAMEWORK_TLP" "$FRAMEWORK_80_100" "$FRAMEWORK_FINGERPRINT" "$TRANSFER_FILES" "$SUNSHINE_SETUP")
	grep -q "$SERVER_SETUP" <<<"$SELECTION" && Server_Setup
	grep -q "$ZFS_REMOTE_UNLOCK" <<<"$SELECTION" && ZFS_Remote_Unlock_Setup
	grep -q "$FRAMEWORK_TLP" <<<"$SELECTION" && Framework_TLP_Setup
	grep -q "$FRAMEWORK_80_100" <<<"$SELECTION" && Framework_80_100_Setup
	grep -q "$FRAMEWORK_FINGERPRINT" <<<"$SELECTION" && Framework_Fingerprint_Setup
	grep -q "$TRANSFER_FILES" <<<"$SELECTION" && Transfer_Files
  grep -q "$SUNSHINE_SETUP" <<<"$SELECTION" && Sunshine_Setup
}

Server_Setup() {
	source /etc/os-release

	if [[ $ID == "debian" ]]; then
		Server_Setup_Debian
	elif [[ $ID == "arch" ]]; then
		Server_Setup_Arch
	else
		echo "Unsupported operating system: $ID"
	fi
}

Server_Setup_Arch() {
	sudo pacman -Syu kitty fish starship
	sudo chsh -s /usr/bin/fish
	echo "Please exit this terminal with the exit command, this is to generate the fish start config"
	fish
	echo "starship init fish | source" >>~/.config/fish/config.fish

	mkdir -p ~/.config/fish/functions
	curl -sL https://raw.githubusercontent.com/Stetsed/.dotfiles/main/.config/fish/functions/nano.fish >~/.config/fish/functions/nano.fish
}

Server_Setup_Debian() {
	curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin
	ln -s ~/.local/kitty.app/bin/kitty /bin/kitty
	ln -s ~/.local/kitty.app/bin/kitten /bin/kitten

	sudo chsh -s /usr/bin/fish

	curl -sS https://starship.rs/install.sh | sh

	echo "Please exit this terminal with the exit command, this is to generate the fish start config"
	fish
	echo "starship init fish | source" >>~/.config/fish/config.fish

	mkdir -p ~/.config/fish/functions
	curl -sL https://raw.githubusercontent.com/Stetsed/.dotfiles/main/.config/fish/functions/nano.fish >~/.config/fish/functions/nano.fish
}

ZFS_Remote_Unlock_Setup() {
	paru -Syu mkinitcpio-netconf mkinitcpio-dropbear

	echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDIezEg3z8pf+9ZoQlscHCrKd72d2sZMtEFyEIZjqSX3uJa0RfHK7miIBXqOEv8A8dlAwUlOP3n+A77TbY6FM5DAM/EFZ4v2Qxz8AJeCJN5YWm+WxE7+NNMIAt88WBtPuNNAmLgnLP10izAjnSJpHU1xc2nW49FoscI5VeoBUCr6UFbgsTqxBWwBBXjCF0dbAh6G1B6zRPkcfhes2aGpnvjrRYDsk3nfzsfMQgsrBrTmehNJDIDiEOQeBwnwsopkMBFKRnvfJ7a8MFnl5Mi19NneScktqpee7tGs7uZruAYmmJh/xm/Hp1Y0YOt/MYN4WAasCVh+n4+Exb0C+5tD7ck+W387440Tmpi1CkuMctB7uHjuUpbOLWh5UYOvQ76//6tWPGZu4/KkY7TXUzshzVvWqOXAk/5NZ45ysZcBn/Qy8Bd4kqrF3vXoHRIEXkZkGky8mcjraRBBUVQUuCgZVIEjgTemsy4ip1OjPN9RCANl8nhyJAMDLArF89dHuzWY50= stetsed@ArchHome" | sudo tee -a /etc/dropbear/root_key

	echo " ip=dhcp" | sudo tee -a /etc/kernel/cmdline

	sudo sed -i 's/zfs/netconf dropbear zfsencryptssh zfs/g' /etc/mkinitcpio.conf

	echo 'ZFS Remote Unlock Setup Complete'
}

Framework_TLP_Setup() {
	paru -Syu tlp

	echo -e "CPU_SCALING_GOVERNOR_ON_AC=performance\nCPU_SCALING_GOVERNOR_ON_BAT=powersave\nCPU_ENERGY_PERF_POLICY_ON_AC=performance\nCPU_ENERGY_PERF_POLICY_ON_BAT=balance_power\nCPU_HWP_DYN_BOOST_ON_AC=1\nCPU_HWP_DYN_BOOST_ON_BAT=1" | sudo tee /etc/tlp.d/01-basic.conf

	sudo systemctl enable tlp.service

	echo "Framework TLP Power Tuning Setup Complete"
}

Framework_80_100_Setup() {
	echo -e "[Unit]\nDescription=Framework Battery Script\n\n[Service]\nExecStart=/home/stetsed/.bin/scripts/framework-battery.sh\n\n[Install]\nWantedBy=multi-user.target" | sudo tee /etc/systemd/system/framework-battery.service

	echo -e "[Unit]\nDescription=Run My Service Every 5 Minutes\n\n[Timer]\nOnCalendar=*:0/5\nUnit=framework-battery.service\n\n[Install]\nWantedBy=timers.target" | sudo tee /etc/systemd/system/framework-battery.timer

	sudo systemctl enable framework-battery.timer

  paru -S fw-ectool-git

	echo "Framework 80-100 Battery Script Setup Complete"
}

Framework_Fingerprint_Setup() {
	paru -S fprintd

	echo -e "#%PAM-1.0\nauth        sufficient      pam_fprintd.so\n\nauth\tinclude\t\tsystem-auth\naccount\tinclude\t\tsystem-auth\nsession\tinclude\t\tsystem-auth" | sudo tee /etc/pam.d/sudo

	echo -e "#\n# PAM configuration file for the swaylock screen locker. By default, it includes\n# the 'login' configuration file (see /etc/pam.d/login)\n#\n\nauth\t\tsufficient\t\tpam_unix.so try_first_pass likeauth nullok\nauth\t\tsufficient\t\tpam_fprintd.so\n\nauth include login" | sudo tee /etc/pam.d/swaylock

	echo -e "#%PAM-1.0\n\nauth\t\tsufficient\t\tpam_unix.so try_first_pass likeauth nullok\n\nauth\t\tinclude\t\tsystem-auth\naccount\t\tinclude\t\tsystem-auth\npassword\t\tinclude\t\tsystem-auth\nsession\t\tinclude\t\tsystem-auth" | sudo tee /etc/pam.d/polkit-1

	echo -e "#%PAM-1.0\n\nauth\t\tsufficient\t\tpam_unix.so try_first_pass likeauth nullok\n\nauth\t\tinclude\t\t\t\t\t\t\t\tsystem-login\naccount\t\tinclude\t\t\t\t\t\t\tsystem-login\npassword\tinclude\t\t\t\t\t\t\tsystem-login\nsession\t\tinclude\t\t\t\t\t\t\tsystem-login" | sudo tee /etc/pam.d/system-local-login

	echo "Framework Fingerprint Setup Complete"
}

Transfer_Files() {
	echo "Would you like to transfer files from the server, or too the server."
	TOO="To the Server"
	FROM="From the Server"
	TRANSFER_SELECTION=$(gum choose "$TOO" "$FROM")
	grep -q "$TOO" <<<"$TRANSFER_SELECTION" && Transfer_Files_Too
	grep -q "$FROM" <<<"$TRANSFER_SELECTION" && Transfer_Files_From
}

Transfer_Files_Too() {
	pkill librewolf
	gum spin -s dot --title "Copying Librewolf Files..." -- cp -r ~/.librewolf ~/Network/Storage/Transfer/

	rm -rf ~/.config/WebCord/Cache/
	pkill webcord
	gum spin -s dot --title "Copying WebCord Files..." -- cp -r ~/.config/WebCord ~/Network/Storage/Transfer/

	gum spin -s dot --title "Copying SSH Files..." -- cp -r ~/.ssh ~/Network/Storage/Transfer/

	gum spin -s dot --title "Copying .env file..." -- cp -r ~/.env ~/Network/Storage/Transfer/
	exit
}

Transfer_Files_From() {
	pkill librewolf
	rm -rf ~/.librewolf
	gum spin -s dot --title "Moving Librewolf Files..." -- mv ~/Network/Storage/Transfer/.librewolf ~/

	pkill webcord
	rm -rf ~/.config/WebCord
	gum spin -s dot --title "Moving WebCord Files..." -- mv ~/Network/Storage/Transfer/WebCord ~/.config/

	rm -rf ~/.ssh
	gum spin -s dot --title "Moving SSH Files..." -- mv ~/Network/Storage/Transfer/.ssh ~/

	rm -rf ~/.env
	gum spin -s dot --title "Moving .env file..." -- mv ~/Network/Storage/Transfer/.env ~/

	gpg --import ~/Network/Storage/Long-Term/stetsed.asc
}

Sunshine_Setup(){
  paru -Syu sunshine

  echo 'KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/85-sunshine.rules

  systemctl --user enable sunshine

  sudo setcap cap_sys_admin+p $(readlink -f $(which sunshine))

  echo "Sunshine Setup Complete, please reboot"
}

Extra_Run
