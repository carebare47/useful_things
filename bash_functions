docker_registry_nuc_ip="10.6.10.7"
this_file_name="bash_functions"
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
winpath_to_linux(){ echo  | sed 's/\/\//g' | sed 's/C:/\/mnt\/c/'; }
upload_latest_firmware_from_container()
{
container_number=$(docker container ls -q);
latest_arduino_build_path=$(docker exec $container_number ls -t /tmp | grep arduino | head -n1);
latest_arduino_build_bin=$(docker exec $container_number ls /tmp/$latest_arduino_build_path | grep bin);
rm $latest_arduino_build_bin || true;
docker cp $container_number:/tmp/$latest_arduino_build_path/$latest_arduino_build_bin . ;
st-flash --reset write $latest_arduino_build_bin 0x8000000 ;
echo "uploaded $latest_arduino_build_bin from $latest_arduino_build_path" ;
}
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
list_dex() { curl -s $docker_registry_nuc_ip:5000/v2/dexterous-hand/tags/list | jq -S '.tags[]' | sort -r | sed -r 's/\"//g' ; }
list_flex() { curl -s $docker_registry_nuc_ip:5000/v2/flexible-hand/tags/list | jq -S '.tags[]' | sort -r | sed -r 's/\"//g' ; }
list_polhemus() { curl -s $docker_registry_nuc_ip:5000/v2/shadow-teleop-polhemus/tags/list | jq -S '.tags[]' | sort -r | sed -r 's/\"//g' ; }
list_teleop() { curl -s $docker_registry_nuc_ip:5000/v2/shadow-teleop/tags/list | jq -S '.tags[]' | sort -r | sed -r 's/\"//g' ; }
list_haptx() { curl -s $docker_registry_nuc_ip:5000/v2/shadow-teleop-haptx/tags/list | jq -S '.tags[]' | sort -r | sed -r 's/\"//g' ; }
list_cyber() { curl -s $docker_registry_nuc_ip:5000/v2/shadow-teleop-cyber/tags/list | jq -S '.tags[]' | sort -r | sed -r 's/\"//g' ; }
list_other() { curl -s $docker_registry_nuc_ip:5000/v2/other/tags/list | jq -S '.tags[]' | sort -r | sed -r 's/\"//g' ; }
list_all() { registry_repo_list_all=$(curl -s $docker_registry_nuc_ip:5000/v2/_catalog | jq -r '.repositories[]')
             registry_repo_list_valid=""
             for repo in $registry_repo_list_all; do
               if [[ $(curl -s $docker_registry_nuc_ip:5000/v2/$repo/tags/list | jq -r '.tags') != 'null' ]]; then registry_repo_list_valid=$(echo "${registry_repo_list_valid}"; echo $repo); fi
             done

             echo "Repos currently in registry: "
             for repo in $registry_repo_list_valid; do
               echo " \"$repo\""
             done
             echo

             echo "Images currently in registry: "
             for repo in $registry_repo_list_valid; do
               repo_name=$(jq ".name" <(curl -s $docker_registry_nuc_ip:5000/v2/$repo/tags/list))
               echo " Images in $repo_name:"
               jq -C ".tags[]" <(curl -s $docker_registry_nuc_ip:5000/v2/$repo/tags/list) | sed 's/^/  /'
               echo
             done
}
delete_image_from_registry() {
  repo=$1
  tag=$2
  digest=$(curl -m 0.1 -k -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json"\
                -X HEAD http://$docker_registry_nuc_ip:5000/v2/$repo/manifests/$tag 2>&1 \
                | grep Etag \
                | awk '{print $3}' \
                | sed -r 's/"//g')
  echo "deleting digest: $digest"
  curl_command=$(echo "curl -k -v --silent -X DELETE http://$docker_registry_nuc_ip:5000/v2/${repo}/manifests/${digest}")
  curl_command=${curl_command%$'\r'}
  ${curl_command}
  echo "Now run garbage collection: "
  echo "docker exec -i registry_2 sh -c \"bin/registry garbage-collect /etc/docker/registry/config.yml\""
}
print_git_config_tom(){ echo -e "git config --global user.name carebare47\ngit config --global user.email tom@shadowrobot.com"; }
install_rosdeps(){ tmp_var=$(pwd); roscd; cd ..; rosdep install --from-paths src --ignore-src -r -y; cd $tmp_var; }
tom_setup() { bash <(curl -Ls bit.ly/tom_setup) -b true -t true; }
print_bash_function_names() { cat ~/.${this_file_name} | grep -E '(\(\)|alias)' | sed -r 's/\{.*//g'; }
