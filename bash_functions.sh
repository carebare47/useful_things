start_last_container() { docker start $(docker ps -an 1 -q) ; }
