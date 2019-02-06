
while [[ $# > 1 ]]
do
key="$1"

case $key in
    -f|--install_fzf)
    FZF="$2"
    shift
    ;;
    *)
    # ignore unknown option
    ;;
esac
shift
done

if [ -z "${FZF}" ];
then
    FZF=false
else 
    FZF=true
fi

if [ ${FZF} = true ]; then
    echo "yes"
else 
    echo "no"
fi

#sudo add-apt-repository ppa:gnome-terminator
#sudo apt-get update
sudo apt-get install -y gedit nano git curl terminator xsel jq
#git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all
#echo "copy() { \"\$1\" | tr -d '\n' | xsel -ib ; }" >> ~/.bashrc
#echo "list_dex() {curl 10.6.10.7:5000/v2/dexterous-hand/tags/list | jq -r ; }" >> ~/.bashrc
#echo "list_flex() {curl 10.6.10.7:5000/v2/flexible-hand/tags/list | jq -r ; }" >> ~/.bashrc
source ~/.bashrc
