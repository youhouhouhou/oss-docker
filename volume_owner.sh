#./volume_owner.sh | grep orphan | awk -F':' '{print $2}'

unnamed_volumes=($(docker volume ls | awk '{if(NR>1)print $2}' | grep '^.\{64,64\}'))
container_ids=($(docker ps -a | awk '{if(NR>1)print $1}'))

#echo "unnamed_volumes: ${unnamed_volumes[@]}"
#echo "container_ids: ${container_ids[@]}"
#echo "--------------------------------------------------------------------------------"

found=()
for container_id in "${container_ids[@]}"; do
    #echo "container_id: ${container_id}"
    container_name="$(docker ps -a | grep ${container_id} | awk '{print $NF}')"
    #echo "container_name: ${container_name}"
    
    for volume in "${unnamed_volumes[@]}"; do
        result="$(docker inspect ${container_id} | grep ${volume})"
        if [ ! -z "${result}" ]; then
            echo "volume:${volume},container_id:${container_id},container_name:${container_name}"
            found+=("${volume}")
        fi
    done
done

orphan=()
for volume in "${unnamed_volumes[@]}"; do
    #echo "volume:${volume}"
    if [[ ! " ${found[@]} " =~ " ${volume} " ]]; then
        echo "orphan:${volume}"
        orphan+=("${volume}")
    fi
done

