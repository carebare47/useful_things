
while [[ $# > 1 ]]
do
key="$1"

case $key in
    -n|--new)
    NEW="$2"
    shift
    ;;
    *)
    # ignore unknown option
    ;;
esac
shift
done

if [ -z "${NEW}" ]; then
    echo "Please pass --new true/false"
    exit 1
fi 
  
  
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
fi
sudo apt-get update
if [ ${NEW} = true ]; then
    sudo apt-get install -y gedit nano git curl terminator xsel jq
    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all    
fi

if [ $(cat ~/.bashrc | grep "list_dex() { curl 10.6.10.7:5000/v2/dexterous-hand/tags/list | jq -r ; }" | wc -l) = 0 ]; then
    echo "list_dex not found, adding..."
    echo "list_dex() { curl 10.6.10.7:5000/v2/dexterous-hand/tags/list | jq -r ; }" >> ~/.bashrc
else 
    echo "list_dex already here, not adding."
fi

if [ $(cat ~/.bashrc | grep "list_flex() { curl 10.6.10.7:5000/v2/flexible-hand/tags/list | jq -r ; }" | wc -l) = 0 ]; then
    echo "list_flex not found, adding..."
    echo "list_flex() { curl 10.6.10.7:5000/v2/flexible-hand/tags/list | jq -r ; }" >> ~/.bashrc
else 
    echo "list_flex already here, not adding."
fi

if [ $(cat ~/.bashrc | grep "copy()" | wc -l) = 0 ]; then
    echo "copy function not found, adding..."
    echo "copy() { \"\$1\" | tr -d '\n' | xsel -ib ; }" >> ~/.bashrc
else 
    echo "copy function already here, not adding."
fi

source ~/.bashrc
