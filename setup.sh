
while [[ $# > 1 ]]
do
key="$1"

case $key in
    -n|--new)
    NEW="$2"
    shift
    ;;
    -s|--shadow)
    SHADOW="$2"
    shift
    ;;    
    *)
    # ignore unknown option
    ;;
esac
shift
done

echo ""
echo "================================================================="
echo "|                                                               |"
echo "|          Queenys linux setup script (watch it grow)           |"
echo "|                                                               |"
echo "================================================================="
echo ""
echo "possible options: "
echo "  * -n or --new                 Set this to tell the script whether it's ran on this machine before (automate this?)"
echo "  * -s or --shadow              Set to true when installing on a shadow machine"
echo ""
echo "example:  bash <(curl -Ls https://raw.githubusercontent.com/carebare47/useful_things/master/setup.sh) --new true -s true"

echo ""
echo "new?              = ${NEW}"
echo "Shadow?           = ${SHADOW}"

confirm() {
    # call with a prompt string or use a default
    read -r -p "${1:-Are you sure? [y/N]} " response
    case "$response" in
        [yY][eE][sS]|[yY]) 
            true
            ;;
        *)
            false
            echo "Okay, exiting now."
            sleep 1
            exit 0
            ;;
    esac
}

if [ -z "${NEW}" ]; then
    echo "Please pass --new true/false"
    exit 1
fi 

if [ -z "${SHADOW}" ]; then   
    SHADOW=false
fi 

if [ ${SHADOW} = false ]; then
    echo "Shadow set to false, shadow-specific commands will not be installed."
else 
    echo "Shadow set to true, shadow-specific functions will be installed."
fi

if [ ${NEW} = false ]; then
    echo "New set to false. Refreshing only·"
else 
    echo "New set to true, installing everything."
    echo "Including: gedit nano git curl terminator xsel jq google-chrome-stable slack & fzf"
fi

confirm "Would you like to continue? [y/n]"
  
if [ ${NEW} = true ]; then
    echo "New flag requested, installing everything"
elif  [ ${NEW} = false ]; then
    echo "No new flag requested, only updating.."
else 
    echo "Status of new flag not recognised, please set to true or false"
    exit 1
fi


if [ ${NEW} = true ]; then
    sudo add-apt-repository ppa:gnome-terminator
    wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 
    sudo sh -c 'echo "deb https://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
    sudo apt-get update
    sudo apt-get install -y gedit nano git curl terminator xsel jq google-chrome-stable
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all    
    sudo snap install slack --classic
fi

if [ ${SHADOW} = true ]; then
    echo "Installing shadow-specific functions.."
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
fi
if [ $(cat ~/.bashrc | grep "copy()" | wc -l) = 0 ]; then
    echo "copy function not found, adding..."
    echo "copy() { \"\$1\" | tr -d '\n' | xsel -ib ; }" >> ~/.bashrc
else 
    echo "copy function already here, not adding."
fi

source ~/.bashrc
