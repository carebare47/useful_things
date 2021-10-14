
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
		-g|--gui)
			GUI="$2"
			shift
			;;
		-s|--silent)
			SILENT="$2"
			shift
			;;			
		*)
			# ignore unknown option
			;;
	esac
	shift
done


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

function autostart() {
	echo "Checking for autostart files..."
	if [ $(ls ~/.config/autostart/ | grep $1 | wc -l) -eq 0 ]; then
		echo "No autostart files found, creating them now ..."
		curl -Ls https://raw.githubusercontent.com/carebare47/useful_things/master/set_startup-script.py | python - $1 $1
	else
		echo "Autostart files found."
	fi
}


if [[ -z "${CONTAINER}" && "${ALL}" == true ]]; then
	CONTAINER=false
fi

if [ -z "${ALL}" ]; then
	ALL=false
fi


if [ -z "${GUI}" ]; then
	GUI=true
fi
#if [ -z "${TOM}" ]; then
#	echo "Are you Tom?"
#	if [[ "$(confirm)" == "y" ]]; then TOM=true ; else TOM=false ; fi
#fi

if [ -z "${CONTAINER}" ]; then
	CONTAINER=false
fi

if [ -z "${BASH_ONLY}" ]; then
	BASH_ONLY=false
fi

if [ -z "${SILENT}" ]; then
	SILENT=false
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
		if [[ "${SILENT}" == false ]]; then
			echo "Do the above settings look correct?"
			if [[ "$(confirm)" == "n" ]]; then echo "exiting..." && exit 0 ; fi
	    	fi
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
        if [[ ${GUI} == true ]]; then 
		sudo apt-get update; sudo apt-get install -y xsel jq gedit gedit-plugins nano tree iputils-ping iproute2 highlight speedometer
	else
		sudo apt-get update; sudo apt-get install -y jq nano tree iputils-ping iproute2 highlight speedometer
	fi
	cat /etc/highlight/filetypes.conf | sed -r 's/\{ Lang=\"xml\", Extensions=\{/\{ Lang=\"xml\", Extensions=\{\"launch\", /g' | sudo tee /etc/highlight/filetypes.conf
	cat /etc/highlight/filetypes.conf | sed -r 's/\{ Lang=\"xml\", Extensions=\{/\{ Lang=\"xml\", Extensions=\{\"xacro\", /g' | sudo tee /etc/highlight/filetypes.conf
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
	sudo apt-get install -y gedit nano git curl xsel jq tree nmap gedit-plugins iputils-ping speedometer
fi

if [[ "${INSTALL_FZF}" == true  ]]; then
	echo "Installing fuzzy history search"
	git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all
fi


if [[ "${BASH_FUNCTIONS}" == true  ]]; then
#	if [[ "$(TOM)" == true ]]; then
#		echo "Configuring git..."
#		git config --global user.email "tom@shadowrobot.com"
#		git config --global user.name "carebare47"
#	fi
        echo "Adding .launch to get xml language file..."
        sudo sed -i 's/\*\.xml;/\*\.xml;\*\.launch;/g' /usr/share/gtksourceview-3.0/language-specs/xml.lang

        echo "Adding .xacro to get xml language file..."
        sudo sed -i 's/\*\.xml;/\*\.xml;\*\.xacro;/g' /usr/share/gtksourceview-3.0/language-specs/xml.lang

	echo "Adding .xacro to get xml language file..."
        sudo sed -i 's/\*\.xml;/\*\.xml;\*\.urdf;/g' /usr/share/gtksourceview-3.0/language-specs/xml.lang

	echo "Installing bash functions..."
        if [[ $(ls ~/ -a | grep -x ".bash_functions" | wc -l) -gt 0 ]]; then
          rm ~/.bash_functions
        fi
        wget -O ~/.bash_functions https://raw.githubusercontent.com/carebare47/useful_things/master/bash_functions
        if [[ $(cat ~/.bashrc  | grep "source ~/.bash_functions" | wc -l) -eq 0 ]]; then
          echo "source ~/.bash_functions" >> ~/.bashrc
        fi

	if [ $(cat ~/.bash_functions | grep "docker_create" | wc -l) -eq 0 ]; then
		echo "docker_create function not found, adding"
		wget -O /tmp/docker_create_function https://raw.githubusercontent.com/carebare47/useful_things/master/docker_create_function
		cat /tmp/docker_create_function >> ~/.bash_functions
		rm /tmp/docker_create_function
	else
		echo "docker_create function already here, not adding."
	fi
	
	echo "Installing eplot & ec..."
	cd /usr/local/bin
	sudo wget https://raw.githubusercontent.com/chriswolfvision/eplot/master/ec
	sudo wget https://raw.githubusercontent.com/chriswolfvision/eplot/master/eplot
	sudo chmod +x ec
	sudo chmod +x eplot
	
	source ~/.bashrc
fi

if [[ "${AUTOSTART_TERMINATOR}" == true  ]]; then
	autostart 'terminator'
fi

if [[ "${INSTALL_SLACK}" == true  ]]; then
	echo "Installing slack..."
	sudo snap install slack --classic
fi

if [[ "${AUTOSTART_SLACK}" == true  ]]; then
	autostart 'slack'
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
