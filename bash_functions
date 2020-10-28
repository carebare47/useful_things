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
grep_gedit() { search_term=$1; grep_all $search_term; read -r -p "${2:-enter substring:} " substring ; file=$(grep_all $search_term | grep $substring | sed -r 's/:.*//g'); echo "opening file: ${file}"; gedit ${file} ; }
catkin_make_all_debug_release_2 () { tmp_var=$(pwd); roscd; cd ../../base_deps; catkin_make_debug_release; cd ../base; catkin_make_debug_release ; cd $tmp_var;  }
setup_new_shadow_container_build_all_2() { mkdir ~/.ssh || true; git_sshify_all_both; setup_new_shadow_container; catkin_make_all_debug_release_2 ; }
copy_etc_hosts() { cat /etc/hosts | grep "10.6" | xsel -ib ; }
rebuild_root_openlase_from_current_subfolder() { 
	current_dir=$(pwd)
	IN="$(pwd)"
	path_components=$(echo $IN | tr "/" "\n")
	openlase_folder_name=$(
	for addr in $path_components
	do
	    echo $addr
	done | grep openlase)

	if [[ $openlase_folder_name != "" ]]; then
		openlase_root_folder=$(pwd | sed -r "s;$openlase_folder_name.*;$openlase_folder_name;g")
		conf="$(confirm "This will remove everything inside ${openlase_root_folder}/build, are you sure? [Y/n]")"
		if [[ $conf == "y" ]]; then
			cd $(pwd | sed -r "s;$openlase_folder_name.*;$openlase_folder_name;g")
			rm -rf build
			mkdir build
			cd build
			cmake .. && make
			cd $current_dir
		else
			echo "fine, whatever"
		fi
	else
		echo "Can't find openlase root folder, giving up."
	fi
}
docker_add_insecure_nuc() { cd /etc/docker; if [[ $(ls | grep daemon | wc -l) == 0 ]]; then touch daemon.json; fi; cat daemon.json | jq '. + {"insecure-registries": ["10.6.10.7:5000"]}' | sudo tee daemon.json; sudo systemctl restart docker.service; }
catkin_make_debug_release_python3() { catkin_make --cmake-args \
            -DCMAKE_BUILD_TYPE=RelWithDebInfo \
            -DPYTHON_EXECUTABLE=/usr/bin/python3.8 \
            -DPYTHON_INCLUDE_DIR=/usr/include/python3.8 \
            -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.8.so \
            -DPYTHON_VERSION=3 ; }

catkin_make_all_debug_release_python3 () { tmp_var=/home/user; roscd; cd ..; catkin_make_debug_release_python3; cd ../base_deps; catkin_make_debug_release_python3 ; cd ;  }
cats() { for input_file in $@; do echo -e "${input_file}: \n"; highlight -O ansi --force -n $input_file; echo -e "\n"; done; }
grep_all_multi() { str=$(for t in $@; do printf "$t|"; done); str2="($(echo $str | rev | cut -c 2- | rev))"; grep -rnE '.' -e "$str2" ; }
diagnostics() { rostopic echo --filter "m.status[0].name == 'Realtime Control Loop'" /diagnostics; }
network_speed() { speedometer -l  -r $1 -t $1 -m $(( 1024 * 1024 * 3 / 2 )) ; }
git_store_credentials() { git config credential.helper cache $1 ; }
bristol_network_speed() { network_speed $(ip addr show | grep 10.6 | awk '{print $8}'); }
