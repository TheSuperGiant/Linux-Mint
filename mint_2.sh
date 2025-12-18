#!/usr/bin/env bash
# Disclaimer:
# This script is provided as-is, without any warranty or guarantee.
# By using this script, you acknowledge that you do so at your own risk.
# I am not responsible for any damage, data loss, or other issues that may result from the use of this script.

#sudo without password
source <(curl -s -L https://raw.githubusercontent.com/TheSuperGiant/Arch/refs/heads/main/parts/without_password_startup.sh)

#variable
source <(curl -s -L https://raw.githubusercontent.com/TheSuperGiant/Arch/refs/heads/main/parts/variable.sh)

total_ram=$(grep MemTotal /proc/meminfo | awk '{print $2}')
ram=$(echo $total_ram / 1000 | bc) #in mb

interface_name=$(ip route | awk '/^default/ {print $5}')

http_check() {
	if [[ "$1" == *"http"* ]];then
		source <(curl -s -L $1)
	else
		source $1
	fi
}

#http_check $1

#check for loaded in functions.

function_sh=$(curl -s https://raw.githubusercontent.com/TheSuperGiant/Arch/refs/heads/main/functions.sh)
function_sh_mint=$(curl -s "https://raw.githubusercontent.com/TheSuperGiant/Linux-Mint/refs/heads/main/functions.sh")
#local if internet isnt availble



for function in "$function_sh" "$function_sh_mint";do
	while IFS= read -r line; do
		if [[ "$line" == alias* ]]; then
			alias=$(echo "$line" | cut -d' ' -f2 | cut -d'=' -f1)
			unalias -a "$alias"
		fi
	done < <(echo "$function")
	source <(echo "$function" | sed -E '/^alias / s/\\"/"/g' | sed -E 's/^alias ([^=]+)=["](.*)["]$/\1() {\n  \2\n}/')
done

pause

ssu

#dns
source <(curl -s -L https://raw.githubusercontent.com/TheSuperGiant/Arch/refs/heads/main/parts/dns.sh)

#special links
source <(curl -s -L https://raw.githubusercontent.com/TheSuperGiant/Arch/refs/heads/main/parts/Special_link.sh)

#function required 1
if [[ $function__update == "1" ]];then 
	function__ap="1"
	function__github_program_updater="1"
fi
if [[ $function__github_program_updater == "1" ]];then
	function__box_sub="1"
fi
if [[ $function__git_u == "1" ]];then
	error="1"
fi

#function required 2
if [[ $function__ap == "1" ]];then
	function__apt_fail="1"
fi
if [[ $function__box_sub == "1" ]];then
	function__box="1"
fi

source <(curl -s -L https://raw.githubusercontent.com/TheSuperGiant/Arch/refs/heads/main/parts/functions_alias_adding.sh)
source <(curl -s -L https://raw.githubusercontent.com/TheSuperGiant/Linux-Mint/refs/heads/main/functions_arch.sh)
for function in $(functi "$function_sh"); do
	if [[ "$(eval echo \${function__arch__$function})" == "1" ]];then
		function_adding "$function" "$function_sh"
	fi
done
for function in $(functi "$function_sh_mint"); do
	function_adding "$function" "$function_sh_mint"
done

for alias in $(aliasi "$function_sh"); do
	if [[ "$(eval echo \${function__arch__$alias})" == "1" ]];then
		alias_adding "$alias" "$function_sh"
	fi
done
for alias in $(aliasi "$function_sh_mint"); do
	alias_adding "$alias" "$function_sh_mint"
done

ubuntu_version_name=$(grep UBUNTU_CODENAME /etc/os-release | cut -d= -f2)

case $ubuntu_version_name in
  bionic) ubuntu_ver="18.04" ;;
  focal)  ubuntu_ver="20.04" ;;
  jammy)  ubuntu_ver="22.04" ;;
  noble)  ubuntu_ver="24.04" ;;
  *) ubuntu_ver="Unknown" ;;
esac
#ubuntu_ver is the version of ubuntu in it.

#broken
##docker
#sudo apt remove docker docker-engine docker.io containerd runc

box_part "apt list update"
sudo apt update

box_part "Debloading"

if ! [[ "$Debloading__linux_mint__usb_image_writer" == "1" && "$Debloading__linux_mint__usb_stick_formatter" == "1" ]];then
	Debloading__linux_mint__usb_image_writer=0
fi

declare -a Debloading__linux_mint=(
	"backup_tool:	mintbackup"
	"calculator:	gnome-calculator"
	"calendar:	gnome-calendar"
	"celluloid:	celluloid"
	"disk_usage_analyzer:	baobab"
	"document_viewer:	xreader"
	"drawing:	drawing"
	"file_renamer:	bulky"
	"fingerprints:	fingwit"
	"firefox:	firefox"
	"hypnotix:	hypnotix"
	"image_viewer:	xviewer"
	"library:	thingy"
	"matrix:	mintchat"
	"nemo:	nemo"
	"notes:	sticky"
	"onboard:	onboard"
	"online_accounts:	gnome-online-accounts-gtk"
	"passwords_and_keys:	seahorse"
	"pix:	pix"
	"power_statistics:	gnome-power-manager"
	"rhythmbox:	rhythmbox"
	"screenshot:	gnome-screenshot"
	"software_manager:	mintinstall"
	"system_reports:	mintreport"
	"text_editor:	xed"
	"thunderbird_mail:	thunderbird"
	"transmission:	transmission-gtk"
	"usb_image_writer:	mintstick"
	"warpinator:	warpinator"
	"web_apps:	webapp-manager"
	"welcome_screen:	mintwelcome"
)

for debload in "${Debloading__linux_mint[@]}"; do
	program_name="${debload%%:*}"
	if [ "$(eval echo   \$Debloading__linux_mint__$program_name)" == "1" ]; then
		apt_name=$(echo "${debload##*:}" | sed -E 's/^[[:space:]]+//')
		sudo apt purge -y "$apt_name" &> /dev/null && echo "$program_name removed." || echo "Failed to remove $program_name."
	fi
done
box_sub "update manager"
Debloading__update_manager(){
	if ! grep -q '^Hidden=true' "$1"; then
		if grep -q '^Hidden=' "$1"; then
			sudo sed -i '/^Hidden=/d' "$1"
		fi
		echo "Hidden=true" | sudo tee -a "$1" > /dev/null && echo "update manager disabled on boot"
	fi
}
if [ "$Debloading__linux_mint__update_manager__system" == "1" ];then
	sudo chmod -x /usr/bin/mintupdate
	Debloading__update_manager "/etc/xdg/autostart/mintupdate.desktop"
elif  [ "$Debloading__linux_mint__update_manager__user" == "1" ];then
	new_path="$HOME/.config/autostart"
	mkdir -p "$new_path"
	cp /etc/xdg/autostart/mintupdate.desktop "$new_path"
	Debloading__update_manager "$new_path/mintupdate.desktop"
fi
box_sub "Removing not used packages"
sudo apt autoremove -y

if [[ $files__linux_mint__background_images == "1" ]];then
	sudo rm -r "/usr/share/backgrounds/linuxmint"
	sudo rm -r "/usr/share/backgrounds/linuxmint-wallpapers"
fi

#add_device_label
source <(curl -s -L https://raw.githubusercontent.com/TheSuperGiant/Arch/refs/heads/main/parts/add_device_label.sh)

tmp(){
	local new_value="tmpfs  /tmp  tmpfs  size=$1,mode=1777  0  0"
	if ! sudo grep -q "$new_value" /etc/fstab; then
		local old_value=$(grep "/tmp" /etc/fstab)
		if [[ "$old_value" != "" ]];then
			sudo sed -i "\|$old_value|d" /etc/fstab
		fi
		sudo bash -c "echo \"$new_value\" >> /etc/fstab" && echo "\tmp moved to ram size set '$1' + added /etc/fstab"
		restart=1
	fi
}
if [[ "$ram__tmp" == 1 ]];then
	if [[ "$ram" -ge "32000" ]];then
		tmp 4G
	elif [[ "$ram" -ge "16000" ]];then
		tmp 2G
	elif [[ "$ram" -ge "8000" ]];then
		tmp 1G
	fi
fi
#switching tmp cleaning disk tmp folder at poweroff must created
#file on the place presits of the git repo download else curl to tmp so it can remove itself.

#personal folders
source <(curl -s -L https://raw.githubusercontent.com/TheSuperGiant/Arch/refs/heads/main/parts/personal_folders.sh)

box_part "updating"

update -g

box_part "installing video drivers"

#drivers
#check the hole dirver part
#gpu=$(inxi -G | grep -i "gpu:" | grep -oE "AMD|NVIDIA|Intel|ASPEED")
if lsmod | grep -qE "nvidia|nouveau"; then
    gpu="nvidia"
else
    # fallback to AMD or Intel detection
    cpu_vendor=$(lscpu | grep 'Vendor ID' | awk '{print $3}')
    gpu=$(lspci | grep -E "VGA|3D" | grep -oE "AMD|Intel|ASPEED" | grep -v "$cpu_vendor" | head -n1)
    gpu=${gpu:-$(lspci | grep -E "VGA|3D" | grep -oE "Intel|AMD|ASPEED" | head -n1)}
fi
#later testing i cannot do it now.
if [[ $gpu == *"nvidia"* ]]; then
    echo "NVIDIA GPU detected"
	#testing drivers check verstion to install
	sudo ubuntu-drivers autoinstall
elif [[ $gpu == *"AMD"* ]]; then
    echo "AMD GPU detected"
	GPU_ID=$(lspci -nn | grep -i amd | awk '{print $6}' | tr -d '[]')
	if modinfo amdgpu | grep -q "$GPU_ID"; then
		echo "Use amdgpu"
	else
		echo "Use legacy radeon"
	fi
elif [[ $gpu == *"Intel"* ]]; then
    echo "Intel GPU detected"
elif [[ $gpu == *"ASPEED"* ]]; then
    echo "ASPEED GPU detected"
else
    echo "No known GPU detected"
fi
#drivers

#before 1
if [ "$Firewall__Default" == "1" ];then
	App_Install__ufw=1
	if [ "$firewall_Recommanded_rules" == "1" ];then
		App_Install__fail2ban=1
	fi
fi
if [[ "$App_Install__hp_printer__on_decetion" == "1" ]];then
	hp=$(lpinfo -v | grep -Ei "direct hp:/|direct hpfax:/|network dnssd://HP|network ipp://HP|network ipps://HP")
	if [[ -n $hp ]];then
		App_Install__hp_printer=1
	fi
fi
if [ "$App_Install__keepass" == "1" ];then
	App_Install__xdotool=1
fi
if [ "$App_Install__librewolf" == "1" ];then
	App_Install__extrepo=1
fi
if [ "$App_Install__notepadPlusPlus" == "1" ];then
	App_Install__wine=1
	App_Install__jq=1
fi
if [ "$App_Install__winboat" == "1" ];then
	App_Install__docker=1
	App_Install__flatpak=1
	restart=1
fi
if [ "$script_main" == "1" ];then
	App_Install__git=1
fi

#before 2
if [[ $App_Install__snap == "1" ]] && ! command -v snap > /dev/null;then
	sudo rm /etc/apt/preferences.d/nosnap.pref
fi



if [ "$App_Install__extrepo" == "1" ];then
	sudo apt install extrepo -y
fi

#before 3

box_part "Adding APT repositories"

#mega based on ubuntu version
#mega=""
mullvad="sudo curl -fsSLo _DIR_/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc; deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$( dpkg --print-architecture )] https://repository.mullvad.net/deb/stable stable main; mullvad"
declare -a apt_addrepo_programs=(
	"brave;	sudo curl -fsSLo _DIR_/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg; deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main; brave-browser-release"
	"docker;	curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o _DIR_/docker-archive-keyring.gpg;deb [arch=amd64 signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu jammy stable; docker"
	"element;	sudo wget -O _DIR_/element-io-archive-keyring.gpg https://packages.element.io/debian/element-io-archive-keyring.gpg ;deb [signed-by=/usr/share/keyrings/element-io-archive-keyring.gpg] https://packages.element.io/debian/ default main; element-io"
	"megasync;	curl -fsSL https://mega.nz/linux/repo/xUbuntu_24.04/Release.key | sudo gpg --dearmor -o _DIR_/mega.gpg; deb [arch=amd64 signed-by=/etc/apt/keyrings/mega.gpg] https://mega.nz/linux/repo/xUbuntu_24.04/ ./; megasync"
	"mullvad_browser;	$mullvad"
	"mullvad_VPN;	$mullvad"
	#"signal;	wget -qO- https://updates.signal.org/desktop/apt/keys.asc | sudo gpg --dearmor -o _DIR_/signal-desktop-keyring.gpg; deb [arch=amd64 signed-by=/usr/share/keyrings/signal-desktop-keyring.gpg] https://updates.signal.org/desktop/apt xenial main; signal-xenial"
	"vivaldi;	wget -qO- https://repo.vivaldi.com/stable/linux_signing_key.pub | sudo gpg --dearmor -o _DIR_/vivaldi-browser.gpg; deb [signed-by=/usr/share/keyrings/vivaldi-browser.gpg] https://repo.vivaldi.com/stable/deb/ stable main; vivaldi"
	#"wire;	wget -qO- https://repo.vivaldi.com/stable/linux_signing_key.pub | sudo gpg --dearmor -o /usr/share/keyrings/vivaldi-browser.gpg; deb [arch=amd64] https://wire-app.wire.com/linux/debian stable main; wire-desktop"
)
for apt_addrepo_program in "${apt_addrepo_programs[@]}"; do
	IFS=';' read -ra apt_addrepo_parts <<< "${apt_addrepo_program}"
	if [ "$(eval echo \$App_Install__${apt_addrepo_parts[0]})" == "1" ]; then
		echo "${apt_addrepo_parts[0]}"
		for i in "${!apt_addrepo_parts[@]}"; do	
			apt_addrepo_parts[$i]="${apt_addrepo_parts[$i]#"${apt_addrepo_parts[$i]%%[! $'\t']*}"}"
		done
		apt_addrepo "${apt_addrepo_parts[1]}" "${apt_addrepo_parts[2]}" "${apt_addrepo_parts[3]}"
	fi
done

if [ "$App_Install__librewolf" == "1" ];then
	sudo extrepo enable librewolf
fi
if [[ "$App_Install__waydroid" == "1" ]] && ! command -v waydroid >/dev/null 2>&1;then
	curl https://repo.waydro.id | sudo bash
fi


box_part "Installing programs"

sudo apt update

#apt install
source <(curl -s -L https://raw.githubusercontent.com/TheSuperGiant/Linux-Mint/refs/heads/main/program_install_list__apt.sh)
for app in "${App_Install[@]}"; do
	key="${app%%:*}"
	if [ "$(eval echo \$App_Install__$key)" == "1" ];then
		box_sub "$key"
		apt install $(echo "${app##*:}" | sed -E 's/^[[:space:]]+//') -y
	fi
done

#after1
if [ "$App_Install__flatpak" == "1" ];then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
fi

#if [ "$App_Install__brew" == "1" ];then
	#apt install git build-essential -y
	#/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	#echo >> /home/giant/.bashrc
   # echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/giant/.bashrc
    #eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
#fi

#after2

if [ "$App_Install__bluetooth" == "1" ];then
	systemctl --user --stop pulseaudio
	systemctl --user --disable pulseaudio
	systemctl --user --replace pipewire pipewire-pulse
	rm -rf ~/.config/pulse
	rm -rf ~/.pulse*
fi
if [ "$App_Install__docker" == "1" ];then
	#sudo usermod -aG docker $USER
	sudo usermod -aG docker $SUDO_USER
	restart=1
fi
if [ "$App_Install__notepadPlusPlus" == "1" ];then
	if ! [ -f "$HOME/.wine/drive_c/Program Files/Notepad++/notepad++.exe" ]; then
		box_sub "notepad++"
		url=$(wget -qO- https://api.github.com/repos/notepad-plus-plus/notepad-plus-plus/releases/latest | grep "browser_download_url" | grep -oP "\"browser_download_url\": \"\K[^\"]*x64.exe\"" | sed 's/"$//')
		wget -O ~/Downloads/npp-latest-installer.exe "$url"
		wine ~/Downloads/npp-latest-installer.exe
	fi
fi
if [ "$App_Install__pcloud" == "1" ];then
	#ensure that the browser is downloading to folder ~/Downloads
	xdg-open "https://www.pcloud.com/how-to-install-pcloud-drive-linux.html?download=electron-64"
	
	if [ "$(echo "$ubuntu_ver >= 24.04" | bc -l 2>/dev/null)" = "1" ]; then
		sudo apt install libfuse2t64 -y
	elif [ "$(echo "$ubuntu_ver < 24.04" | bc -l 2>/dev/null)" = "1" ]; then
		sudo apt install libfuse2 -y
	fi
	
	#after that
	
	#chmod +x ~/Downloads/pcloud
	#~/Downloads/pcloud &
fi

#flatpak list
source <(curl -s -L https://raw.githubusercontent.com/TheSuperGiant/Linux-Mint/refs/heads/main/program_install_list__Flatpak.sh)
for app in "${App_Install[@]}"; do
	key="${app%%:*}"
	if [ "$(eval echo \$App_Install__$key)" == "1" ];then
		box_sub "$key"
		flatpak install $(echo "${app##*:}" | sed -E 's/^[[:space:]]+//') -y
	fi
done

if [ "$App_Install__losslesscut" == "1" ];then
	flatpak override --user --filesystem=home no.mifi.losslesscut
fi
if [ "$App_Install__virtualbox" == "1" ];then
	sudo systemctl stop libvirtd
	sudo modprobe -r kvm_amd
	echo "blacklist kvm_amd" | sudo tee /etc/modprobe.d/blacklist-kvm.conf
fi
if [ "$game_dependencies" == "1" ];then
	#this must be still tested
	sudo apt install python3-pyqt5 python3-pip git pipx -y
	sudo pipx ensurepath
	#https://github.com/DavidoTek/ProtonUp-Qt/
	#pipx install protonup-qt
	#pip3 install protonup-qt
	protonup-qt
fi

#github_program_updater
source <(curl -s -L https://raw.githubusercontent.com/TheSuperGiant/Linux-Mint/refs/heads/main/parts/github_program_updater_programs.sh)
github_program_updater_programs



box_part "Secutity settings"

if [ "$Firewall__Default" == "1" ];then
	sudo ufw enable
	if [ "$firewall_Recommanded_rules" == "1" ];then
		sudo ufw default deny incoming
		sudo ufw default allow outgoing
		#sudo systemctl enable --now fail2ban
	fi
	
	if [[ "$App_Install__waydroid" == "1" ]];then
		sudo ufw allow in on waydroid0
		sudo ufw allow out on waydroid0
		#building in function later that it can add row of code in it if needed for some programs
		#sudo nano /etc/ufw/before.rules
		#under this
		# End required lines
		#-A FORWARD -i waydroid0 -o $interface_name -j ACCEPT 
		#-A FORWARD -i $interface_name -o waydroid0 -m state --state ESTABLISHED,RELATED -j ACCEPT
		#sudo ufw reload #maby adding this after file eddit to automatic reload.
		
		
		#restart=1 #only needed if ufw reload does not go to add in the g_firewall function
	fi
fi

#settings
source <(curl -s -L https://raw.githubusercontent.com/TheSuperGiant/Arch/refs/heads/main/parts/settings.sh)

#github repos
if [[ "$script_main" == 1 || "$script_startup" == 1 ]];then
	git_repo__thesupergiant__linux_mint=1
fi

#github updater
source <(curl -s -L https://raw.githubusercontent.com/TheSuperGiant/Arch/refs/heads/main/parts/github_git_repo.sh)

if [[ "$App_Install__waydroid" == "1" ]];then
	#list based on variable.
	sudo waydroid init -s GAPPS
	sudo modprobe binder_linux
	sudo modprobe ashmem_linux
fi

if [[ "$restart" == "1" ]];then
	r="restart required"
	echo -e "\n\n\n"
	echo -e "\e[1;93m$r\e[0m"
	echo -e "\n\n\n"
fi