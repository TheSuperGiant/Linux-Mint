declare -a github_program_updater_programs=(
	"rustdesk:	rustdesk; rustdesk; -s;rustdesk.*x86_64.*; -R;1"
	"session:	session-desktop; session-foundation"
	"thorium:	thorium; Alex313031; -s;thorium-browser.*; -R;1"
	"winboat:	winboat; tibixdev"
)
for github_program in "${github_program_updater_programs[@]}"; do
	program_name="${github_program%%:*}"
	prameters="${github_program##*:}"
	if [ "$(eval echo \$App_Install__$program_name)" == "1" ]; then
		IFS=';' read -ra prameters_parts <<< "${prameters}"
		for i in "${!prameters_parts[@]}"; do
			prameters_parts[$i]="$(sed 's/^[[:space:]]*//' <<<"${prameters_parts[$i]}")"
		done
		echo "$program_name"
		github_program_updater -r "${prameters_parts[0]}" -u "${prameters_parts[1]}" "${prameters_parts[@]:2}"
	fi
done