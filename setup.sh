sudo apt-get install -y gedit nano git 
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf && ~/.fzf/install --all
echo "copy() { \"\$1\" | tr -d '\n' | xsel -ib ; }" >> ~/.bashrc
source ~/.bashrc
