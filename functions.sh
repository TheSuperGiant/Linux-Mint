apt_addrepo(){
	download_location="/run"
	save_location="/etc/apt/keyrings/"
	gpg_name=$(echo "$1" | grep -oP '_DIR_\S+' | xargs -I{} bash -c 'echo "${1##*/}"' _ {})
	download_location_file="$download_location/$gpg_name"
	save_location_file="$save_location/$gpg_name"
	execution="${1//_DIR_/$download_location}"; execution="${execution//gpg --dearmor -o/gpg --dearmor --yes -o}"
	eval "$execution"
	new_gpg=$(gpg --show-keys "$download_location_file")
	old_gpg=$(gpg --show-keys "$save_location_file" 2>/dev/null)
	if [[ "$old_gpg" != "$new_gpg" ]]; then
		sudo cp "$download_location_file" "$save_location_file"
		echo "GPG key updated for repository."
	fi
	list_file="/etc/apt/sources.list.d/$3.list"
	old_value=$(cat $list_file 2>/dev/null)
	new_value="${2/\/usr\/share\//\/etc\/apt\/}"
	if [[ "$new_value" != "$old_value" ]];then
		echo "$new_value"| sudo tee $list_file > /dev/null
		echo "apt repository .list updated"
	fi
	echo "------------------------------------"
}
github_program_updater(){
	error() {
		printf "\e[1;91m\n\n$1\e[0m\n\n"
	}
	help_text() {
		echo "github program updater
		
Downloading and installing/updating programs

github_program_updater <parameters>

parameters 
  -r --repo		[text] repo name in github.
  -u --user		[text] user name in github
	
parameters (optional)
  -i --installed		[text] Remove from the string in the installed version.
  -o --online		[text] Remove from the string in the online version.
  -R --row		[number] Select the correct row if multiple entries exist.
  -s --search		[text] searchstring for download url
	
parameters (view variable value)
  -I --info		get variable value of: 'url online_version installed_version'
  -j --json		open the url of the json file from github.
	

example:
github_program_updater -r \"qwerty\" -u \"keyboard\"
github_program_updater -r \"qwerty\" -u \"keyboard\" -s \"qwerty.*x86_64.*\" -R \"1\" -o \" \" -i\" \"
github_program_updater -r \"qwerty\" -u \"keyboard\" -I
github_program_updater -r \"qwerty\" -u \"keyboard\" -j"
	}
	if [[ $# == 0 ]] || printf '%s\n' "$@" | grep -qE '^-(h|help)$|^--help$'; then
		help_text
		return
	fi
	while [[ $# -gt 0 ]]; do
        case "$1" in
            -I|-info|--info)
                local info=1
                shift
                ;;
            -i|-installed|--installed)
                local installed="$2"
                shift 2
                ;;
            -j|-json|--json)
                local json=1
                shift
                ;;
            -o|-online|--online)
                local online="$2"
                shift 2
                ;;
            -r|-repo|--repo)
                local repo="$2"
                shift 2
                ;;
            -R|-row|--row)
                local row="$2"
                shift 2
                ;;
            -s|-search|--search)
                local search="$2"
                shift 2
                ;;
            -u|-user|--user)
                local user="$2"
                shift 2
                ;;
            *)
                echo "Unknown option: $1"
				help_text
                return
                ;;
        esac
    done
	local url="https://api.github.com/repos/$user/$repo/releases/latest"
	local json_url=$(wget -qO- $url)
	if [[ -z "$repo" && -z "$user" ]];then
		help_text
		error "--repo (-r) and --user (-u) are required"
		return
	fi
	if [[ "$json" == 1 ]];then
		xdg-open "$url"
		return
	fi
	local online_version=$(echo "$json_url" | grep -oP '"tag_name": "\K(.*)(?=")' | sed 's/-.*//' | tr -cd '0-9.')
	#if online version must stript -o -online --onilne
	if dpkg -l | grep -q "^ii.*$repo"; then
		#local installed_version=$(dpkg -l | grep $repo | awk 'NR==1 {print $3}')
		local installed_version=$(dpkg -l | grep $repo | awk 'NR==1 {print $3}' | sed 's/-.*//' | tr -cd '0-9.')
	fi
	#if local installed version must stript. -i -installed --installed
	local url=$(echo "$json_url" | grep "browser_download_url" | grep -oP "\"browser_download_url\": \"\K[^\"]*$search\.deb\"")
	if [[ -n "$row" ]];then
		local url=$(echo "$url" | head -n $row)
	fi
	local url=$(echo "$url" | sed 's/"$//')
	if [[ "$info" == 1 ]];then
		printf "url:\n$url\n\n\n"
		printf "online version:\n$online_version\n\n\n"
		printf "installed version:\n$installed_version\n\n\n"
		return
	fi
	if [[ "$online_version" != "$installed_version" ]];then
		if [[ "${url##*.}" != "deb" ]];then
			error "only .deb file supported"
			printf '%s\n' "url: $url"
			return
		fi
		wget -O ~/Downloads/$repo-latest.deb "$url"
		apt install ~/Downloads/$repo-latest.deb -y
		#sudo -v #maby temeory
		#sudo dpkg -i ~/Downloads/$repo-latest.deb
		#sudo apt install -y ~/Downloads/$repo-latest.deb &
		#sudo DEBIAN_FRONTEND=noninteractive apt install -y ~/Downloads/$repo-latest.deb || true
		#apt install ~/Downloads/$repo-latest.deb -y || true
		#sudo DEBIAN_FRONTEND=noninteractive apt install -y ~/Downloads/$repo-latest.deb >/dev/null 2>&1 || true
	fi
}












#sudo dpkg --configure -a
#sudo apt-get install -f
#sudo apt-get update
#sudo apt-get upgrade
update(){
	sudo apt update
	while [[ $updates != 0 ]]; do
		sudo mintupdate-cli upgrade -y
		updates=$(mintupdate-cli list | wc -l)
	done
}