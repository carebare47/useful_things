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
copy() { "$1" | tr -d '\n' | xsel -ib ; }
git_update_all() { ls | xargs -I{} git -C {} pull ; }
git_print_log() { git log --graph --oneline --decorate --all ; }
scan_shadow_ports() { nmap -p 22 --open -sV 10.6.10.0/24 ; }
grep_all() { grep -rn '.' -e "$1" ; }
debug_bash() { PS4='\033[0;33m+(\${BASH_SOURCE}:\${LINENO}):\033[0m \${FUNCNAME[0]:+\${FUNCNAME[0]}(): }' bash -x $1 ; }
git_add_ssh() { eval "$(ssh-agent -s)"; ssh-add ~/.ssh/id_rsa ; }
test_sr_ur10() { roslaunch sr_robot_launch sr_right_ur10arm_hand.launch sim:=true scene:=true ; }
git config --global alias.sshify '!f() { git remote set-url origin $(git remote get-url origin | sed -En "s/https:\/\/github.com\//git@github.com:/p") ; }; f'
git config --global alias.unsshify '!f() { git remote set-url origin $(git remote get-url origin | sed -En "s/git@github.com:/https:\/\/github.com\//p") ; }; f'
git_sshify_all_both() { roscd; cd ../src; git_sshify_all; cd ../../base_deps/src; git_sshify_all ; }
setup_new_shadow_container_build_all() { mkdir ~/.ssh || true; git_sshify_all_both; setup_new_shadow_container; catkin_make_all_debug_release ; }
setup_new_shadow_container() { git_add_ssh; roscd; cd ../src; git_update_all; cd ../../base_deps/src; git_update_all; }
git_unsshify_all_both() { roscd; cd ../src; git_unsshify_all; cd ../../base_deps/src; git_unsshify_all ; }
git_sshify_all() { ls | xargs -I{} git -C {} sshify ; }
git_unsshify_all() { ls | xargs -I{} git -C {} unsshify ; }
catkin_make_debug_release() { catkin_make -DCMAKE_BUILD_TYPE=RelWithDebInfo ; }
catkin_make_all_debug_release () { tmp_var=$(pwd); roscd; cd ..; catkin_make_debug_release; cd ../base_deps; catkin_make_debug_release ; cd $tmp_var;  }
catkin_make_all () { tmp_var=$(pwd); roscd; cd ..; catkin_make; cd ../base_deps; catkin_make ; cd $tmp_var; }
nvidialise(){ bash <(curl -Ls https://github.com/shadow-robot/sr-build-tools/raw/master/docker/utils/docker2_nvidialize.sh) $1 ; }
alias please="sudo" # please_alias
oneliner_old() { echo "bash <(curl -Ls https://raw.githubusercontent.com/shadow-robot/sr-build-tools/F%23SRC-1077-make-it-work-with-nvidia-docker2/docker/launch.sh) -i 10.6.10.7:5000/flexible-hand:kinetic-v0.2.69 -bt F#SRC-1077-make-it-work-with-nvidia-docker2 -b kinetic_devel -n flexible -sn flex -e enp0s25 -l false -r true -g true -nv 2" ; }
docker_add_insecure_nuc() { cd /etc/docker; if [[ $(ls | grep daemon | wc -l) == 0 ]]; then touch daemon.json; fi; cat daemon.json | jq '. + {"insecure-registries": ["10.6.10.7:5000"]}' | sudo tee daemon.json; sudo systemctl restart docker.service; }
catkin_make_debug_release_python3() { catkin_make --cmake-args \
            -DCMAKE_BUILD_TYPE=RelWithDebInfo \
            -DPYTHON_EXECUTABLE=/usr/bin/python3.8 \
            -DPYTHON_INCLUDE_DIR=/usr/include/python3.8 \
            -DPYTHON_LIBRARY=/usr/lib/x86_64-linux-gnu/libpython3.8.so \
            -DPYTHON_VERSION=3 ; }

catkin_make_all_debug_release_python3 () { tmp_var=/home/user; roscd; cd ..; catkin_make_debug_release_python3; cd ../base_deps; catkin_make_debug_release_python3 ; cd ;  }
cats() { for input_file in $@; do echo -e "${input_file}: \n"; highlight -O ansi --force $input_file; echo -e "\n"; done; }
catsn() { for input_file in $@; do echo -e "${input_file}: \n"; highlight -O ansi --force -n $input_file; echo -e "\n"; done; }
grep_all_multi() { str=$(for t in $@; do printf "$t|"; done); str2="($(echo $str | rev | cut -c 2- | rev))"; grep -rnE '.' -e "$str2" ; }
diagnostics() { rostopic echo --filter "m.status[0].name == 'Realtime Control Loop'" /diagnostics; }
network_speed() { speedometer -l  -r $1 -t $1 -m $(( 1024 * 1024 * 3 / 2 )) ; }
git_store_credentials() { git config credential.helper cache $1 ; }
docker_registry_nuc_ip="10.6.10.7"
list_dex() { curl -s $docker_registry_nuc_ip:5000/v2/dexterous-hand/tags/list | jq -S '.tags[]' | sort -r | sed -r 's/\"//g' ; }
list_flex() { curl -s $docker_registry_nuc_ip:5000/v2/flexible-hand/tags/list | jq -S '.tags[]' | sort -r | sed -r 's/\"//g' ; }
list_polhemus() { curl -s $docker_registry_nuc_ip:5000/v2/shadow-teleop-polhemus/tags/list | jq -S '.tags[]' | sort -r | sed -r 's/\"//g' ; }
list_teleop() { curl -s $docker_registry_nuc_ip:5000/v2/shadow-teleop/tags/list | jq -S '.tags[]' | sort -r | sed -r 's/\"//g' ; }
list_haptx() { curl -s $docker_registry_nuc_ip:5000/v2/shadow-teleop-haptx/tags/list | jq -S '.tags[]' | sort -r | sed -r 's/\"//g' ; }
list_cyber() { curl -s $docker_registry_nuc_ip:5000/v2/shadow-teleop-cyber/tags/list | jq -S '.tags[]' | sort -r | sed -r 's/\"//g' ; }
list_other() { curl -s $docker_registry_nuc_ip:5000/v2/other/tags/list | jq -S '.tags[]' | sort -r | sed -r 's/\"//g' ; }

