sudo add-apt-repository ppa:gnome-terminator
sudo apt-get update
sudo apt-get install -y gedit nano git curl terminator
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all
echo "copy() { \"\$1\" | tr -d '\n' | xsel -ib ; }" >> ~/.bashrc
source ~/.bashrc
