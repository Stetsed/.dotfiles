#!/bin/bash

Extra_Run() {
	echo "Script designed to allow extra install/setup functions to be provided, use at your own risk."
	ZFS_REMOTE_UNLOCK="ZFS Remote Unlock Setup"
	FRAMEWORK_TLP="Framework TLP Setup"
	FRAMEWORK_80_100="Framework 80/100 Power Setup"
	FRAMEWORK_FINGERPRINT="Framework Fingerprint Setup"
	TRANSFER_FILES="Transfer Files"
	SUNSHINE_SETUP="Setup Sunshine"
	AUTO_SHUTDOWN="Auto Shutdown"
	INSTALL_VENCORD="Install Vencord"
	SELECTION=$(gum choose "$ZFS_REMOTE_UNLOCK" "$FRAMEWORK_TLP" "$FRAMEWORK_80_100" "$FRAMEWORK_FINGERPRINT" "$TRANSFER_FILES" "$SUNSHINE_SETUP" "$AUTO_SHUTDOWN" "$INSTALL_VENCORD")
	grep -q "$ZFS_REMOTE_UNLOCK" <<<"$SELECTION" && ZFS_Remote_Unlock_Setup
	grep -q "$FRAMEWORK_TLP" <<<"$SELECTION" && Framework_TLP_Setup
	grep -q "$FRAMEWORK_80_100" <<<"$SELECTION" && Framework_80_100_Setup
	grep -q "$FRAMEWORK_FINGERPRINT" <<<"$SELECTION" && Framework_Fingerprint_Setup
	grep -q "$TRANSFER_FILES" <<<"$SELECTION" && Transfer_Files
	grep -q "$SUNSHINE_SETUP" <<<"$SELECTION" && Sunshine_Setup
	grep -q "$AUTO_SHUTDOWN" <<<"$SELECTION" && Auto_Shutdown
	grep -q "$INSTALL_VENCORD" <<<"$SELECTION" && Install_Vencord
}

ZFS_Remote_Unlock_Setup() {
	paru -Syu mkinitcpio-netconf mkinitcpio-dropbear

	echo "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIChekNRGHiQU2u+jWCSElqXG5St/FgfSVhncALLwmV1y" | sudo tee -a /etc/dropbear/root_key

	echo " ip=dhcp" | sudo tee -a /etc/kernel/cmdline

	sudo sed -i 's/zfs/netconf dropbear zfsencryptssh zfs/g' /etc/mkinitcpio.conf

	echo "Do you want to make it down the enp8s0 interface so br0 can take over."
	choose2=$(gum choose "Yes" "No")

	if [[ $choose2 == "Yes" ]]; then
		echo -e "[Unit]\nDescription=Script\nAfter=network-online.target\nWants=network-online.target\n\n[Service]\nExecStart=/usr/bin/nmcli connection down enp8s0" | sudo tee /etc/systemd/system/enp8s0-down.service
		sudo systemctl enable enp8s0-down.service
	fi

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

	echo -e "#\n# PAM configuration file for the swaylock screen locker. By default, it includes\n# the 'login' configuration file (see /etc/pam.d/login)\n#\n\nauth\t\tsufficient\t\tpam_unix.so try_first_pass likeauth nullok\nauth\t\tsufficient\t\tpam_fprintd.so\n\nauth include login" | sudo tee /etc/pam.d/hyprlock

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

	pkill brave
	mkdir -p ~/Network/Storage/Transfer/Brave
	gum spin -s dot --title "Copying Brave Profiles Files..." -- cp -r ~/.config/BraveSoftware/Brave-Browser/Profile\ 1 ~/Network/Storage/Transfer/Brave
	gum spin -s dot --title "Copying Brave Profiles Files..." -- cp -r ~/.config/BraveSoftware/Brave-Browser/Default ~/Network/Storage/Transfer/Brave

	pkill discord
	gum spin -s dot --title "Copying Discord Files..." -- cp -r ~/.config/Vencord ~/Network/Storage/Transfer/

	exit
}

Transfer_Files_From() {
	pkill librewolf
	rm -rf ~/.librewolf
	gum spin -s dot --title "Moving Librewolf Files..." -- mv ~/Network/Storage/Transfer/.librewolf ~/

	pkill brave
	rm -rf ~/.config/BraveSoftware/Profile*
	rm -rf ~/.config/BraveSoftware/Default
	gum spin -s dot --title "Moving brave files..." -- mv ~/Network/Storage/Transfer/Brave/* ~/.config/BraveSoftware/Brave-Browser/

	pkill discord
	rm -rf ~/.config/Vencord
	gum spin -s dot --title "Moving Discord Files..." -- mv ~/Network/Storage/Transfer/Vencord ~/.config/

	gpg --import ~/Network/Storage/Long-Term/stetsed.asc

	echo "66F394E23D4E3ADA88F03F93F8D00D233E9EBCE4:6:" | gpg --import-ownertrust
}

Sunshine_Setup() {
	paru -Syu sunshine

	echo 'KERNEL=="uinput", SUBSYSTEM=="misc", OPTIONS+="static_node=uinput", TAG+="uaccess"' | sudo tee /etc/udev/rules.d/85-sunshine.rules

	systemctl --user enable sunshine

	sudo setcap cap_sys_admin+p $(readlink -f $(which sunshine))

	echo "Sunshine Setup Complete, please reboot"
}

Auto_Shutdown() {
	echo -e "[Unit]\nDescription=Run Auto Shutdown Script Every 5 Minutes\n\n[Timer]\nOnBootSec=10min\nOnUnitActiveSec=5min\nPersistent=true\n\n[Install]\nWantedBy=timers.target" | sudo tee /etc/systemd/system/auto_shutdown.timer
	echo -e "[Unit]\nDescription=Auto Shutdown Script\n\n[Service]\nType=simple\nExecStart=/home/$(whoami)/.bin/scripts/auto_shutdown.sh\n\n[Install]\nWantedBy=default.target" | sudo tee /etc/systemd/system/auto_shutdown.service
	sudo systemctl enable --now auto_shutdown.timer
}

Install_Vencord() {
	wget -O vencord https://github.com/Vendicated/VencordInstaller/releases/latest/download/VencordInstallerCli-Linux
	chmod +x vencord
	if command -v sudo &>/dev/null; then
		sudo ./vencord -branch stable -install -install-openasar
	elif command -v doas &>/dev/null; then
		doas ./vencord -branch stable -install -install-openasar
	else
		echo "Please install sudo or doas"
	fi

	rm vencord
}

Extra_Run
