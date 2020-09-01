#!/bin/bash
# Requires 'jq': https://stedolan.github.io/jq/
#set -e

# set username and password
UNAME="USERNAME"
UPASS="PASSWORD"

registry_container_name="registry_2"
local_ip_address="10.6.10.7"

NUM_RESULTS=2
keep_last_n_months=4

repo_list=$(echo "dexterous-hand
other_repos_here")

images_to_keep=$( echo "dexterous-hand:kinetic-release
dexterous-hand:melodic-release")

get_tags_from_repo() {
  local image_tags=$(curl -s -H "Authorization: JWT $1" https://hub.docker.com/v2/repositories/shadowrobot/$2/tags/?page_size=${NUM_RESULTS} | jq -r '.results|.[]|.name')
  echo "$image_tags"
}

concatenate_list() {
  for j in $2
  do
    local FULL_IMAGE_LIST="${FULL_IMAGE_LIST} shadowrobot/$1:${j}"
  done
  echo $FULL_IMAGE_LIST
}

# tested with strings, works
delete_image_from_registry() {
  repo=$1
  tag=$2
  digest=$(curl -m 0.1 -k -v --silent -H "Accept: application/vnd.docker.distribution.manifest.v2+json"\
                -X HEAD http://localhost:5000/v2/$repo/manifests/$tag 2>&1 \
                | grep Etag \
                | awk '{print $3}' \
                | sed -r 's/"//g')
  echo "deleting digest: $digest"
  curl_command=$(echo "curl -k -v --silent -X DELETE http://localhost:5000/v2/${repo}/manifests/${digest}")
  curl_command=${curl_command%$'\r'}
  ${curl_command}
}

echo ""
echo "########################################################################"
echo "########################################################################"
echo ""
echo "Script start time: $(date)"
echo "########################################################################" >> /home/shadowop/working_docker_shadow_sync/logs/timelog_clean.txt
echo "Script start time: $(date)" >> /home/shadowop/working_docker_shadow_sync/logs/timelog_clean.txt
echo "" >> /home/shadowop/working_docker_shadow_sync/logs/timelog_clean.txt
echo


echo "Aquiring token..."
TOKEN=$(curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${UNAME}'", "password": "'${UPASS}'"}' https://hub.docker.com/v2/users/login/ | jq -r .token)


for repo in $repo_list; do 
  echo ""
  echo "Getting image list from $repo:"
  IMAGE_TAGS=$(get_tags_from_repo "$TOKEN" "$repo")
  for image in $IMAGE_TAGS; do echo -e "\t$image"; done
  FULL_IMAGE_LIST=$( concatenate_list "$repo" "$IMAGE_TAGS")
done

echo "Images:"
for image in $FULL_IMAGE_LIST; do echo "$image"; done

# Pull images from FULL_IMAGE_LIST, unless we've already got them in our registry
for image in $FULL_IMAGE_LIST; do
  repo=$(echo $image | sed -r 's/:.*//g' | sed -r 's;shadowrobot/;;g')
  #echo "repo: ${repo}"
  tag=$(echo $image | sed -r 's;.*:;;g')
  #echo "tag: ${tag}"
  if [[ $(curl -s 10.6.10.7:5000/v2/$repo/tags/list | jq -r '.tags' | grep "\"$tag\"" | wc -l) -eq 0 ]]; then
    echo "pulling $image: $repo:$tag"
    docker pull $image
    echo "Retagging image $image as ${local_ip_address}:5000/${repo}:${tag}"
    docker image tag $image ${local_ip_address}:5000/${repo}:${tag}
    docker push ${local_ip_address}:5000/${repo}:${tag}
    echo "Removing local images (this won't remove them from the local registry)"
    docker rmi ${local_ip_address}:5000/${repo}:${tag}
    # keep a copy of night build and release local to nuc (outside registry) so that new ones automatically pull but current ones don't re-pull
    if [[ $(echo $tag | grep "night-build" | wc -l) -eq 0 ]]; then
      if [[ $(echo $tag | grep "release" | wc -l) -eq 0 ]]; then
        docker rmi $image
      fi
    fi
  else
    echo "not pulling $image ::: Already exists!"
  fi
done

for image in $images_to_keep; do
  repo=$(echo $image | sed -r 's/:.*//g' | sed -r 's;shadowrobot/;;g')
  echo "repo: ${repo}"
  tag=$(echo $image | sed -r 's;.*:;;g')
  echo "tag: ${tag}"
  image="shadowrobot/$repo:$tag"
  if [[ $(curl -s 10.6.10.7:5000/v2/$repo/tags/list | jq -r '.tags'| grep "\"$tag\"" | wc -l) -eq 0 ]]; then
    docker pull $image
    docker image tag $image ${local_ip_address}:5000/${repo}:${tag}
    docker push ${local_ip_address}:5000/${repo}:${tag}
    docker rmi ${local_ip_address}:5000/${repo}:${tag}
    docker rmi $image
  fi
done
#exit 0


####################################################################################################################################
####################################################################################################################################

# This works in theory, find images older then x months and marks them for deletion. However there is something wrong with the garbage collection. Tag can be deleted but data can't yet

# Check creation date of all images in the registry and mark images for deletion that are older than $keep_last_n_months
for repo in $repo_list; do
  tag_list=$(curl -s localhost:5000/v2/$repo/tags/list | jq -r '.tags' | sed -r 's;("|,|\[|\]);;g')
  for tag in $tag_list; do
    tag=${tag//$'\n'/}
    tag="${tag##*( )}"
    got_json=$(curl -s -X GET http://localhost:5000/v2/$repo/manifests/$tag)
    if [[ $(echo $got_json) != *"MANIFEST_UNKNOWN"* ]]; then
      date_created=$(curl -s -X GET http://localhost:5000/v2/$repo/manifests/$tag \
                         | jq -r '.history[].v1Compatibility' \
                         | jq '.created' \
                         | sort \
                         | tail -n1 \
                         | sed -r 's/"//g' \
                         | sed -r 's/T.*//g') || true
      comparison_date=$(date -d "$keep_last_n_months months ago" +"%Y-%m-%d")
      if [[ $( date -d $date_created +%s) < $( date -d $comparison_date +%s) ]] ; then 
        if [[ $(echo "$images_to_keep" | grep "$repo:$tag" | wc -l) -eq 0 ]]; then
          echo "Deleting $repo:$tag as it's older than $keep_last_n_months months"
          delete_image_from_registry "$repo" "$tag"
        fi
      fi
    else
      echo "Something went wrong when removing $repo:$tag from the registry, skipping..."
    fi
  done
done

# Run garbage collection to delete marked images from registry
docker exec -i $registry_container_name sh -c "bin/registry garbage-collect /etc/docker/registry/config.yml"


echo "Finished. Images currently in registry: "
for repo in $repo_list; do
  echo
  repo_name=$(jq ".name" <(curl -s $local_ip_address:5000/v2/$repo/tags/list))
  echo "Images in $repo_name:"
  jq ".tags[]" <(curl -s $local_ip_address:5000/v2/$repo/tags/list)
done
echo
echo "Try one of the following commands to see what images are in this registry: "
for repo in $repo_list; do 
  echo "curl -s $local_ip_address:5000/v2/$repo/tags/list | tac | tac | jq -r"
done
echo
echo "Script end time: $(date)"
echo "Script end time: $(date)" >> /home/shadowop/working_docker_shadow_sync/logs/timelog_clean.txt
echo ""
echo "########################################################################"
echo "########################################################################"
echo ""

