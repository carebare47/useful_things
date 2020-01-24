function confirm() {
	# call with a prompt string or use a default
	read -r -p "${1:-[y/N]} " response
	case "$response" in
		[yY][eE][sS]|[yY])
			echo "y"
			return 1
			;;
		*)
			echo "n"
			return 0
			;;
	esac
}
start_last_container() { docker start $(docker ps -an 1 -q) ; }
alias cgrep="grep --color=always"
ps_aux() { ps aux | cgrep $1 | grep -v grep ; }
kill_all_ros() { sudo kill -9 $(ps_aux ros | awk '{print $2}') ; }
ps_aux_command() { ps -e -o command | cgrep $1 | grep -v grep ; }
kill_any_process() { ps_aux_command $1; conf="$(confirm "kill these processes? [Y/n]")"; if [[ $conf == "y" ]]; then echo "killing..."; sudo kill -9 $(ps_aux $1 | awk {'print $2}'); sleep 1; echo "remaining: "; ps_aux_command $1 else echo "not killing"; fi ; }
docker_exec () { if [[ $(docker container ls -q | wc -l) -eq 1 ]]; then docker exec -it $(docker container ls -q) bash -c "su user"; else echo "wrong number of containers running"; fi; }
aurora_install() { bash <(curl -Ls bit.ly/run-aurora) install_software software=['$1'] ; }
aurora_install_vscode() { aurora_install vscode ; }
grep_gedit() { search_term=$1; grep_all $search_term; read -r -p "${2:-enter substring:} " substring ; gedit $(grep_all $search_term | grep $substring | sed -r 's/:.*//g') ; }
