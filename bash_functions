base_ws="/home/user/projects/shadow_robot/base/src"
docker_registry_nuc_ip="10.6.10.7"
this_file_name="bash_functions"
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Color_Off='\033[0m'       # Text Reset
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
aurora_install() { bash <(curl -Ls bit.ly/run-aurora) install_software software=["$1"] ; }
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
docker_add_insecure_nuc() { cd /etc/docker; if [[ $(ls | grep daemon | wc -l) == 0 ]]; then sudo touch daemon.json; echo -e "{\n\n}" | sudo tee daemon.json; fi; cat daemon.json | jq '. + {"insecure-registries": ["10.6.10.7:5000"]}' | sudo tee daemon.json; sudo systemctl restart docker.service; }
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

             echo "Night build dates: "
             for repo in $registry_repo_list_valid; do 
               repo_name=$(jq ".name" <(curl -s $docker_registry_nuc_ip:5000/v2/$repo/tags/list))
               night_build_tags=$(jq -C ".tags[]" <(curl -s $docker_registry_nuc_ip:5000/v2/$repo/tags/list) | sed 's/^/  /' | grep "melodic-night-build" )
               if [[ $(echo $night_build_tags) != "" ]]; then
                 date=$(curl -s -X GET http://$docker_registry_nuc_ip:5000/v2/$repo/manifests/melodic-night-build | jq -r '.history[].v1Compatibility' | jq '.created' | sort | tail -n1)
                 image_date=$(date -d $(echo $date | tr -d "\"" | cut -c1-19) +%Y%m%d)
                 current_date=$(date +%Y%m%d)
                 if [[ $image_date -ge $current_date ]]; then 
                   echo -e "${Green}Date ${repo}:melodic-night-build was created: $(date -d $(echo $date | tr -d "\"" | cut -c1-19) +%Y-%m-%d). Up to date! ${Color_Off}"
                 else
                   echo -e "${Yellow}Date ${repo}:melodic-night-build was created: $(date -d $(echo $date | tr -d "\"" | cut -c1-19) +%Y-%m-%d), whereas todays date is $(date +%Y-%m-%d). There should be a newer image out by now. Please run registry_nuc_update. ${Color_Off}"
                 fi
               fi
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
rosdep_install() { rosdep install --from-paths src --ignore-src -r -y ; }
install_rosdeps(){ tmp_var=$(pwd); cd $base_ws; cd ../../base_deps; rosdep_install; cd $base_ws; cd ..; rosdep_install; cd $tmp_var; }
tom_setup() { bash <(curl -Ls bit.ly/tom_setup) -b true -t true; }
print_bash_function_names() { cat ~/.${this_file_name} | grep -E '(\(\)|alias)' | sed -r 's/\{.*//g'; }
run_remote_script(){
USER_NAME=$1
IP_ADDRESS=$2
DIRECTORY=$3
SCRIPT_NAME=$4
ssh -X $USER_NAME@$IP_ADDRESS DIRECTORY=$DIRECTORY SCRIPT_NAME=$SCRIPT_NAME 'bash -s' <<'ENDSSH'
cd ${DIRECTORY}
./${SCRIPT_NAME}
ENDSSH
}
registry_nuc_update(){ run_remote_script shadowop $docker_registry_nuc_ip working_docker_shadow_sync clean_image_pull.sh; }
git_sizes(){
IFS=$'\n';
# list all objects including their size, sort by size, take top 10
objects=`git verify-pack -v .git/objects/pack/pack-*.idx | grep -v chain | sort -k3nr | head`
echo "All sizes are in kB's. The pack column is the size of the object, compressed, inside the pack file."
output="size,pack,SHA,location"
allObjects=`git rev-list --all --objects`
for y in $objects
do
    # extract the size in bytes
    size=$((`echo $y | cut -f 5 -d ' '`/1024))
    # extract the compressed size in bytes
    compressedSize=$((`echo $y | cut -f 6 -d ' '`/1024))
    # extract the SHA
    sha=`echo $y | cut -f 1 -d ' '`
    # find the objects location in the repository tree
    other=`echo "${allObjects}" | grep $sha`
    #lineBreak=`echo -e "\n"`
    output="${output}\n${size},${compressedSize},${other}"
done
echo -e $output | column -t -s ', ' 
}
bfg(){
BFG_FILENAME="bfg-1.13.0.jar"
BFG_URL="https://repo1.maven.org/maven2/com/madgag/bfg/1.13.0/bfg-1.13.0.jar"
if [[ $(ls ~/ | grep $BFG_FILENAME | wc -l ) -eq 0 ]]; then
  wget $BFG_URL -O ~/${BFG_FILENAME}
fi
CUR_DIR=$(pwd)
cd ~/
java -jar $BFG_FILENAME $@ $CUR_DIR
cd $CUR_DIR
}
set_PID() { joint=$1; p=$2; i=$3; d=$4; rosservice call /ra_trajectory_controller/gains/ra_${joint}_joint/set_parameters "config:
  bools:
  - {name: '', value: false}
  ints:
  - {name: '', value: 0}
  strs:
  - {name: '', value: ''}
  doubles:
  - {name: 'p', value: $p}
  - {name: 'i', value: $i}
  - {name: 'd', value: $d}
  - {name: 'i_clamp', value: 1.0}
  groups:
  - {name: '', state: false, id: 0, parent: 0}"; }
bristol_network_speed() { network_speed $(ip addr show | grep 10.6 | awk '{print $8}'); }
remove_moveit() { cd $base_ws && rm -rf moveit && sudo apt-get install -y ros-melodic-moveit* && install_rosdeps && cd $base_ws && cd .. && rm -rf build devel && catkin_make_debug_release && catkin_make_all_debug_release ; }
set_PID_all() { p=$1; i=$2; d=$3; for joint in $(echo "elbow shoulder_lift shoulder_pan wrist_1 wrist_2 wrist_3"); do echo $joint; set_PID $joint $p $i $d; done; }
get_PID_all() { if [[ $1 == "" ]]; then side="ra"; else side=$1; fi; for joint in $(echo "elbow shoulder_lift shoulder_pan wrist_1 wrist_2 wrist_3"); do for var in $(echo "p i d"); do value=$(rosparam get "/${side}_trajectory_controller/gains/${side}_${joint}_joint/${var}"); echo "${joint}_${var}: $value" ;done; done; }
autostart_program() { curl -Ls https://raw.githubusercontent.com/carebare47/useful_things/master/set_startup-script.py | python - $1 $1 ; }

# f_name(){ echo "TFQ_${1}"; }
# FILENAME="$(f_name remote_mouse_keepalive)"
# DIRECTORY="/home/user/RemoteMouse"
# PID_SEARCH_1="mono"
# PID_SEARCH_2="RemoteMouse" 
# COMMAND_STR="mono RemoteMouse.exe"

# echo_keepalive_script(){ echo '#!/bin/bash
# ps_aux() { ps aux | grep $1 | grep -v grep ; }'; echo "cd $2
# while true; do if [[ \$(ps_aux $3 | grep $4 | wc -l) -eq 0 ]]; then $5; else sleep 1; fi; sleep 1; done
# " ;}

# echo_keepalive_script ${FILENAME} ${DIRECTORY} ${PID_SEARCH_1} ${PID_SEARCH_2} ${COMMAND_STR} >> ~/.local/bin/${FILENAME}
# autostart_program ${FILENAME}
catkin_make_all_n(){ 
excluded_packages_base_deps=$(rospack list | grep /home/user/projects/shadow_robot/base_deps/src/moveit | awk '{print $1}' | paste -s -d ';')
excluded_packages_base=$(rospack list | grep /home/user/projects/shadow_robot/base/src/moveit | awk '{print $1}' | paste -s -d ';')
tmp_var=$(pwd); roscd; cd ../; catkin_make -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCATKIN_BLACKLIST_PACKAGES="$excluded_packages_base"; roscd; cd ../../base_deps; catkin_make -DCMAKE_BUILD_TYPE=RelWithDebInfo -DCATKIN_BLACKLIST_PACKAGES="$excluded_packages_base_deps" ; cd $tmp_var;  }
ros_lint_py_here() { for file in $(find . -name "*py"); do echo $file; rosrun roslint pep8 --max-line-length=120 $file; done ; }
dev_diff(){
  ls /dev | sed -r $'s/ /\\n/g' > /tmp/diff_1 ;
  bool_dev_diff=false ;
  echo "Please plug or unplug device now..." ;
  while [[ $bool_dev_diff == false ]]; do 
    ls /dev | sed -r $'s/ /\\n/g' > /tmp/diff_2;
    if [[ $(diff /tmp/diff_1 /tmp/diff_2) ]]; then
      echo -E "device diff detected, waiting a few seconds for other drivers to start..." ;
      echo
      sleep 3 ;
      ls /dev | sed -r $'s/ /\\n/g' > /tmp/diff_2;
      bool_dev_diff=true;
      break;
    fi;
  done ;
  diff /tmp/diff_1 /tmp/diff_2 ; }
google() { if [[ $(which sr | wc -l) -eq 0 ]]; then sudo apt-get install -y surfraw && mkdir -p ~/.config/surfraw/ && for line in $(echo "SURFRAW_text_browser=/usr/bin/www-browser"; echo "SURFRAW_graphical=no"); do echo $line >> ~/.config/surfraw/conf ; done; fi; str="$*"; echo "google $str"; bash -c "sr google $str"; }
fix_ros_keys() { sudo apt-key adv --keyserver 'hkp://keyserver.ubuntu.com:80' --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654; }
