declare -a required=(
	#1
	"function__github_program_updater:	box_sub error"
	"function__update:	ap github_program_updater"
	#2
	"function__ap:	apt_fail"
)

source <(curl -s -L https://raw.githubusercontent.com/TheSuperGiant/Arch/refs/heads/main/parts/functions_needs__require_loop.sh)
