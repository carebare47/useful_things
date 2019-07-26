
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

while [[ $# > 1 ]]
do
	key="$1"

	case $key in
		-c|--container)
			CONTAINER="$2"
			shift
			;;
		-b|--bash_only)
			BASH_ONLY="$2"
			shift
			;;			
		-a|--all)
			ALL="$2"
			shift
			;;
		-t|--tom)
			TOM="$2"
			shift
			;;			
		*)
			# ignore unknown option
			;;
	esac
	shift
done

if [[ -z "${CONTAINER}" && "${ALL}" == true ]]; then
	CONTAINER=false
fi

if [ -z "${ALL}" ]; then
	ALL=false
fi
if [ -z "${TOM}" ]; then
	echo "Are you Tom?"
	if [[ "$(confirm)" == "y" ]]; then TOM=true ; else TOM=false ; fi
fi

if [ -z "${CONTAINER}" ]; then
	CONTAINER=false
fi

if [ -z "${BASH_ONLY}" ]; then
	BASH_ONLY=false
fi


echo ""
echo "================================================================="
echo "|                                                               |"
echo "|                 Queenys linux setup script                    |"
echo "|                                                               |"
echo "================================================================="
echo ""
echo "possible options: "
echo "  * -a or --all                 Set to true to do everything (use on new machine)"
echo "  * -c or --container           Set to true when installing in a container (e.g. doesn't install chrome)"
echo "  * -b or --bash_only           Set to true to only install bash functions"
echo ""
echo "example:  bash <(curl -Ls https://raw.githubusercontent.com/carebare47/useful_things/master/setup.sh) --all true -c true"
echo "You might need this: curl -H 'Cache-Control: no-cache'"
echo ""
echo "All?	        = ${ALL}"
echo "Container?        = ${CONTAINER}"
echo "BASH_ONLY?        = ${BASH_ONLY}"



if [[ "${CONTAINER}" == true && "${ALL}" == true ]]; then
	echo "Container and all are mutually-exclusive!"
	exit 1
fi

if [[ "${BASH_ONLY}" == false ]]; then
	if [[ "${CONTAINER}" == false ]]; then
		echo "Do the above settings look correct?"
		if [[ "$(confirm)" == "n" ]]; then echo "exiting..." && exit 0 ; fi
	fi
	
	if [[ "$ALL" == false && "$CONTAINER" == false ]]; then
	
		echo "Install bash functions?"
		if [[ "$(confirm)" == "y" ]]; then BASH_FUNCTIONS=true ; else BASH_FUNCTIONS=false ; fi
		
		echo "Install fzf?"
		if [[ "$(confirm)" == "y" ]]; then INSTALL_FZF=true ; else INSTALL_FZF=false ; fi
		
		echo "Install peek?"
		if [[ "$(confirm)" == "y" ]]; then INSTALL_PEEK=true ; else INSTALL_PEEK=false ; fi
			
		echo "Install packages?"
		if [[ "$(confirm)" == "y" ]]; then INSTALL_PACKAGES=true ; else INSTALL_PACKAGES=false ; fi
	
		echo "Install terminator?"
		if [[ "$(confirm)" == "y" ]]; then INSTALL_TERMINATOR=true ; else INSTALL_TERMINATOR=false ; fi
	
		echo "Autostart terminator?"
		if [[ "$(confirm)" == "y" ]]; then AUTOSTART_TERMINATOR=true ; else AUTOSTART_TERMINATOR=false ; fi
	
		echo "Install slack?"
		if [[ "$(confirm)" == "y" ]]; then INSTALL_SLACK=true ; else INSTALL_SLACK=false ; fi
	
		echo "Autostart slack?"
		if [[ "$(confirm)" == "y" ]]; then AUTOSTART_SLACK=true ; else AUTOSTART_SLACK=false ; fi
	
		echo "Install chrome?"
		if [[ "$(confirm)" == "y" ]]; then INSTALL_CHROME=true ; else INSTALL_CHROME=false ; fi
	
	elif [[ "$CONTAINER" == true ]]; then
	
		BASH_FUNCTIONS=true
		INSTALL_SLACK=false
		AUTOSTART_SLACK=false
		INSTALL_CHROME=false
		AUTOSTART_TERMINATOR=false
		INSTALL_TERMINATOR=false
		INSTALL_PACKAGES=true
		INSTALL_FZF=true
		INSTALL_PEEK=false
		
	elif [[ "$ALL" == true ]]; then
	
		BASH_FUNCTIONS=true
		INSTALL_SLACK=true
		AUTOSTART_SLACK=true
		INSTALL_CHROME=true
		AUTOSTART_TERMINATOR=true
		INSTALL_TERMINATOR=true
		INSTALL_PACKAGES=true
		INSTALL_FZF=true
		INSTALL_PEEK=true
	fi	
else

	BASH_FUNCTIONS=true
	INSTALL_FZF=true
	sudo apt-get update; sudo apt-get install -y xsel jq gedit gedit-plugins nano tree
	INSTALL_SLACK=false
	AUTOSTART_SLACK=false
	INSTALL_CHROME=false
	AUTOSTART_TERMINATOR=false
	INSTALL_TERMINATOR=false
	INSTALL_PACKAGES=false
	INSTALL_PEEK=false
fi


if [[ "${INSTALL_PEEK}" == true  ]]; then
	echo "Adding peek ppa..."
	sudo add-apt-repository ppa:peek-developers/stable	
	echo "peek ppa added"
fi

if [[ "${INSTALL_TERMINATOR}" == true  ]]; then
	echo "Adding terminator ppa..."
	sudo add-apt-repository ppa:gnome-terminator
	echo "Terminator ppa added"
fi

if [[ "${INSTALL_CHROME}" == true  ]]; then
	echo "Adding chrome ppa..."
	sudo sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list'
	wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add -
fi

if [[ "${INSTALL_TERMINATOR}" == true  ]]; then
	sudo apt-get update
	sudo apt-get install -y terminator
fi
	
if [[ "${INSTALL_PEEK}" == true  ]]; then
	sudo apt-get update
	sudo apt-get install -y peek
fi	

if [[ "${INSTALL_PACKAGES}" == true  ]]; then
	echo "Installing packages"
	sudo apt-get update
	sudo apt-get install -y gedit nano git curl xsel jq tree nmap gedit-plugins
fi

if [[ "${INSTALL_FZF}" == true  ]]; then
	echo "Installing fuzzy history search"
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all
fi


if [[ "${BASH_FUNCTIONS}" == true  ]]; then
	if [[ "$(TOM)" == true ]]; then
		echo "Configuring git..."
		git config --global user.email "tom@shadowrobot.com"
		git config --global user.name "carebare47"
	fi
	echo "Installing bash functions..."
	if [ $(cat ~/.bashrc | grep "list_dex()" | wc -l) = 0 ]; then
		echo "list_dex not found, adding..."
		echo "list_dex() { curl -s 10.6.10.7:5000/v2/dexterous-hand/tags/list | jq -r ; }" >> ~/.bashrc
	else
		echo "list_dex already here, not adding."
	fi

	if [ $(cat ~/.bashrc | grep "list_flex()" | wc -l) = 0 ]; then
		echo "list_flex not found, adding..."
		echo "list_flex() { curl -s 10.6.10.7:5000/v2/flexible-hand/tags/list | jq -r ; }" >> ~/.bashrc
	else
		echo "list_flex already here, not adding."
	fi

	if [ $(cat ~/.bashrc | grep "list_teleop()" | wc -l) = 0 ]; then
		echo "list_teleop not found, adding..."
		echo "list_teleop() { curl -s 10.6.10.7:5000/v2/shadow-teleop/tags/list | jq -r ; }" >> ~/.bashrc
	else
		echo "list_teleop already here, not adding."
	fi

	if [ $(cat ~/.bashrc | grep "oneliner()" | wc -l) = 0 ]; then
		echo "echo oneliner not found, adding..."
		echo "oneliner() { echo \"bash <(curl -Ls https://raw.githubusercontent.com/shadow-robot/sr-build-tools/F%23SRC-1077-make-it-work-with-nvidia-docker2/docker/launch.sh) -i 10.6.10.7:5000/flexible-hand:kinetic-v0.2.69 -bt F#SRC-1077-make-it-work-with-nvidia-docker2 -b kinetic_devel -n flexible -sn flex -e enp0s25 -l false -r true -g true -nv 2\" ; }" >> .bashrc
	else
		echo "echo oneliner already here, not adding."
	fi

	if [ $(cat ~/.bashrc | grep "copy()" | wc -l) = 0 ]; then
		echo "copy function not found, adding..."
		echo "copy() { \"\$1\" | tr -d '\n' | xsel -ib ; }" >> ~/.bashrc
	else
		echo "copy function already here, not adding."
	fi
	if [ $(cat ~/.bashrc | grep "git_update_all()" | wc -l) = 0 ]; then
		echo "git_update_all function not found, adding..."
		echo "git_update_all() { ls | xargs -I{} git -C {} pull ; }" >> ~/.bashrc
	else
		echo "git_update_all function already here, not adding."
	fi
	
	if [ $(cat ~/.bashrc | grep "git_print_log()" | wc -l) = 0 ]; then
		echo "git_print_log function not found, adding..."
		echo "git_print_log() { git log --graph --oneline --decorate --all ; }" >> ~/.bashrc
	else
		echo "git_print_log function already here, not adding."
	fi

	if [ $(cat ~/.bashrc | grep "scan_shadow_ports()" | wc -l) = 0 ]; then
		echo "scan_shadow_ports function not found, adding..."
		echo "scan_shadow_ports() { nmap -p 22 --open -sV 10.6.10.0/24 ; } " >> ~/.bashrc
	else
		echo "scan_shadow_ports function already here, not adding."
	fi

	if [ $(cat ~/.bashrc | grep "grep_all()" | wc -l) = 0 ]; then
		echo "grep_all function not found, adding..."
		echo "grep_all() { grep -rn '.' -e \"\$1\" ; } " >> ~/.bashrc
	else
		echo "grep_all function already here, not adding."
	fi
	
	if [ $(cat ~/.bashrc | grep "debug_bash" | wc -l) = 0 ]; then
		echo "debug_bash not found, adding..."
		echo "debug_bash() { PS4='\033[0;33m+(\${BASH_SOURCE}:\${LINENO}):\033[0m \${FUNCNAME[0]:+\${FUNCNAME[0]}(): }' bash -x \$1 ; }" >> ~/.bashrc
	else 
	        echo "debug_bash function already here, not adding."
	fi
	source ~/.bashrc
fi

if [[ "${AUTOSTART_TERMINATOR}" == true  ]]; then
	echo "Checking for autostart files..."
	if [ $(ls ~/.config/autostart/ | grep terminator | wc -l) = 0 ]; then
		echo "No autostart files found, creating them now ..."
		wget https://raw.githubusercontent.com/carebare47/useful_things/master/set_startup-script.py -P /tmp/startup_script/
		cd /tmp/startup_script/
		python3 set_startup-script.py 'terminator' 'terminator'
		cd -
	else
		echo "Autostart files found."
	fi
fi

if [[ "${INSTALL_SLACK}" == true  ]]; then
	echo "Installing slack..."
	sudo snap install slack --classic
fi

if [[ "${AUTOSTART_SLACK}" == true ]]; then
	echo "Checking for autostart files..."
	if [ $(ls ~/.config/autostart/ | grep slack | wc -l) = 0 ]; then
		echo "No autostart files found, creating them now ..."
		wget https://raw.githubusercontent.com/carebare47/useful_things/master/set_startup-script.py -P /tmp/startup_script/
		cd /tmp/startup_script/
		python3 set_startup-script.py 'slack' 'slack'
		cd -
	else
		echo "Autostart files found."
	fi
fi

if [[ "${INSTALL_CHROME}" == true  ]]; then
	sudo apt-get update
	sudo apt-get install -y google-chrome-stable
fi

echo ""
echo "================================================================="
echo "|                                                               |"
echo "|                           Finished!                           |"
echo "|                                                               |"
echo "================================================================="
echo ""
