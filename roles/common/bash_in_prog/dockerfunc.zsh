#!/bin/bash

script_name=$0
echo $script_name
# Bash wrappers for docker run commands

export DOCKER_REPO_PREFIX=jess
# export DOCKER_REPO_PREFIX=doesitscript
#  docker rm -v $(docker ps -aq -f 'status=exited')
#  docker rmi $(docker images -aq -f 'dangling=true')
#  this will also remove volumes of docker-compose if the containers are barely stopped
#  docker volume rm $(docker volume ls -q -f 'dangling=true')
#
# Helper Functions
#
# Since Snow Leopard (10.6), up to Mojave (10.14), every version of macOS supports this:

# sudo lsof -iTCP -sTCP:LISTEN -n -P

# Personally I've end up with this simple function in my ~/.bash_profile:
docker_host_setup() {
	sudo ifconfig lo0 alias 10.200.10.1/24  # (where 10.200.10.1 is some unused IP address) #
	export DOCKER_HOST_IP=10.200.10.1
	docker run -p 8889:8888 -e DOCKER_DIAGNOSTICS_PORT=8889 -e DOCKER_HOST_IP \
     --rm eventuateio/eventuateio-docker-networking-diagnostics:0.2.0.RELEASE
}



listening() {
    if [ $# -eq 0 ]; then
        sudo lsof -iTCP -sTCP:LISTEN -n -P
    elif [ $# -eq 1 ]; then
        sudo lsof -iTCP -sTCP:LISTEN -n -P | grep -i --color $1
    else
        echo "Usage: listening [pattern]"
    fi
}

function kill_all_like_name () {
	if [ -n "$1" ]; then
		# ps aux | grep -ie "$1" | awk '{print "sudo kill -9 " $2}'
		ps aux | grep -ie "java" | awk '{print $2}'
		ps aux | grep -ie "java" | awk '{print $2}' | xargs kill -9
		# | awk '{print $2}' | xargs kill -9
	else
		echo "missing process to kill "
	fi

}


#Not docker, just useful
function killport_port() {
	lsof -i TCP:"$1" | grep LISTEN | awk '{print $2}' | xargs kill -9

}
# function killport() { lsof -i TCP:$1 | grep LISTEN | awk '{print $2}' | xargs kill -9 }

function dcleanup(){
	local containers
	IFS=' ' containers=$(datamash -t ' ' transpose <<<$(docker ps -aq 2>/dev/null))
	# mapfile -t containers < <(docker ps -aq 2>/dev/null)
	docker rm "${containers[@]}" 2>/dev/null
	# Jess's
	local volumes
	IFS=' ' volumes=$(datamash -t ' ' transpose <<<$(docker ps --filter status=exited -q 2>/dev/null))
	# mapfile -t volumes < <(docker ps --filter status=exited -q 2>/dev/null)
	docker rm -v "${volumes[@]}" 2>/dev/null
	local vols
	IFS=' ' vols=$(datamash -t ' ' transpose <<<$(docker volume ls -q))
	# mapfile -t volumes < <(docker ps --filter status=exited -q 2>/dev/null)
	docker volume rm "${vols[@]}" 2>/dev/null
	local images
	IFS=' ' images=$(datamash -t ' ' transpose <<<$(docker images --filter dangling=true -q 2>/dev/null))
	# mapfile -t images < <(docker images --filter dangling=true -q 2>/dev/null)
	docker rmi "${images[@]}" 2>/dev/null
}


function del_stopped_forced(){
	local name=$1
	local state
	state=$(docker inspect --format "{{.State.Running}}" "$name" 2>/dev/null)
	echo "The state was: $state"
	docker rm "$name" --force
}

function del_stopped(){
	local name=$1
	local state
	state=$(docker inspect --format "{{.State.Running}}" "$name" 2>/dev/null)

	if [[ "$state" == "false" ]]; then
		docker rm "$name"
	elif [[ "$state" == "true" ]]; then
		docker stop "$name"
		docker rm "$name"
	fi

}

function relies_on(){
	for container in "$@"; do
		local state
		state=$(docker inspect --format "{{.State.Running}}" "$container" 2>/dev/null)

		if [[ "$state" == "false" ]] || [[ "$state" == "" ]]; then
			echo "$container is not running, starting it for you."
			$container
		fi
	done
}

function nginx(){
	del_stopped nginx

	docker run -d \
		--restart always \
		-p 80:80 \
		-p 8080:8080 \
		# -v "${HOME}/.nginx:/etc/nginx" \
		-v "${HOME}/.nginx:/etc/nginx" \
		-v /var/run/docker.sock:/tmp/docker.sock:ro \
		--net host \
		--name nginx \
		nginx

# 	# add domain to hosts & open nginx
# 	sudo hostess add josh 127.0.0.1
# 	# sudo hostess add jess 127.0.0.1
	echo "NOTICE: NGINX running as a service now"
	echo  "mv /usr/local/etc/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf.bak"
	echo  "ln -s /Users/i859113/.nginx/conf.d/kube.api.conf /usr/local/etc/nginx/nginx.conf"
	echo  "brew services start nginx"
	echo  "curl localhost:80"
	echo  "docker-for-desktop/default"
}

# creates terraboard and runs a postgres database with external volume to persist
function terraboard_with_docker_db(){
	delete_terraboard=$1
	delete_postgres=$2
	delete_postgres_volume=$3
	# USAGE=$(cat <<-END
    USAGE="Three parameters available in order:
    delete_terraboard bool and is set to ${delete_terraboard}
    delete_postgres bool and is set to ${delete_postgres}
	delete_postgres_volume bool and is set to ${delete_postgres_volume}

	run the following to test:
	aws --profile bd-gbl-root-admin s3 ls s3://bd-ue2-root-tfstate"
	# END
	# )

	echo "$USAGE"
	export POSTGRES_PASSWORD=Pass@W0rd1

	export AWS_DYNAMODB_TABLE=bd-ue2-root-tfstate-lock
	export AWS_BUCKET=bd-ue2-root-tfstate

	PROFILE=bd-gbl-root-admin
	export AWS_ACCESS_KEY_ID=$(aws configure get $PROFILE.aws_access_key_id)
	export AWS_SECRET_ACCESS_KEY=$(aws configure get $PROFILE.aws_secret_access_key)
	export AWS_SESSION_TOKEN=$(aws configure get $PROFILE.aws_session_token)
	export AWS_DEFAULT_REGION=$(aws configure get $PROFILE.region)

	# echo $AWS_ACCESS_KEY_ID
	# echo $AWS_SECRET_ACCESS_KEY
	# echo $AWS_SESSION_TOKEN
	# echo $AWS_DEFAULT_REGION

	if [[ -z "${AWS_ACCESS_KEY_ID}" ]]; then
        echo "$(tput setaf 1)"WARNING "\${AWS_ACCESS_KEY_ID}" variable is empty"$(tput sgr0)"
    fi
	if [[ -z "${AWS_SECRET_ACCESS_KEY}" ]]; then
        echo "$(tput setaf 1)"WARNING "\${AWS_SECRET_ACCESS_KEY}" variable is empty"$(tput sgr0)"
    fi
	if [[ -z "${AWS_SESSION_TOKEN}" ]]; then
        echo "$(tput setaf 1)"WARNING "\${AWS_SESSION_TOKEN}" variable is empty"$(tput sgr0)"
    fi
	if [[ -z "${AWS_DEFAULT_REGION}" ]]; then
        echo "$(tput setaf 1)"WARNING "\${AWS_DEFAULT_REGION}" variable is empty"$(tput sgr0)"
    fi

	# for item in "${AWS_KEYS[@]}"; do
    # echo "value of \${item}: ${item}"

    # if [[ -z "${item}" ]]; then
    #     echo "$(tput setaf 1)"WARNING "\${item}" variable is empty"$(tput sgr0)"
    # fi
	# done

	if [ "${delete_postgres}" ]; then
		echo "Deleting postgres, container only"
		docker rm --force db
	fi

	docker volume create pgdata
	# if [ -s "${delete_postgres_volume}" ]; then
	if [ "${delete_postgres_volume}" ]; then
		echo "Deleting volume pgdata"
		docker volume rm pgdata
	fi

	# Create network for db and app to communicate
	docker network create terraboardnet

	docker run --name db \
	-e POSTGRES_USER=gorm \
	-e POSTGRES_DB=gorm \
	-e POSTGRES_PASSWORD=${POSTGRES_PASSWORD} \
	-e GODEBUG="netdns=go" \
	-v pgdata:/var/lib/postgresql/data \
	--net terraboardnet \
	--detach \
	--restart=always \
	postgres:9.5
	# docker volume rm

	sleep 10
	if [ "${delete_terraboard}" ]; then
		echo "Deleting terraboard"
		docker rm --force terraboard
	fi

	docker run --name terraboard -p 8080:8080 \
	-e AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
	-e AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
	-e AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}" \
	-e AWS_REGION="${AWS_DEFAULT_REGION}" \
	-e AWS_BUCKET="${AWS_BUCKET}" \
	-e AWS_DYNAMODB_TABLE="${AWS_DYNAMODB_TABLE}" \
	-e DB_PASSWORD="${POSTGRES_PASSWORD}" \
	-e DB_SSLMODE="disable" \
	--net terraboardnet \
	camptocamp/terraboard:latest

}

# creates an nginx config for a local route
function nginx_config(){
	server=$1
	route=$2

	# mkdir -p ~/.nginx/conf.d
	mkdir -p ~/.nginx/conf.d

	rm -rf "${HOME}/.nginx/conf.d/${server}.conf"
	cat >"${HOME}/.nginx/conf.d/${server}.conf" <<-EOF
	upstream ${server} { server ${route}; }
	server {
	server_name ${server};

	location / {
	proxy_pass  http://${server};
	proxy_http_version 1.1;
	proxy_set_header Upgrade \$http_upgrade;
	proxy_set_header Connection "upgrade";
	proxy_set_header Host \$http_host;
	proxy_set_header X-Forwarded-Proto \$scheme;
	proxy_set_header X-Forwarded-For \$remote_addr;
	proxy_set_header X-Forwarded-Port \$server_port;
	proxy_set_header X-Request-Start \$msec;
}
	}
	EOF

	# restart nginx
	docker restart nginx

	# add host to /etc/hosts
	sudo hostess add "$server" 127.0.0.1

	# open browser
	open "http://${server}"
	# browser-exec "http://${server}"
}

#
# Container Aliases
#
apt_file(){
	docker run --rm -it \
		--name apt-file \
		${DOCKER_REPO_PREFIX}/apt-file
}
alias apt-file="apt_file"
audacity(){
	del_stopped audacity

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-e QT_DEVICE_PIXEL_RATIO \
		--device /dev/snd \
		--group-add audio \
		--name audacity \
		${DOCKER_REPO_PREFIX}/audacity
}
# TODO setup profile and configuration in ansible rol
# aws(){
# 		# -w "${HOME}" \
# 		# -v "${pwd}:${HOME}" \
# 	docker run -it --rm \
# 		-v "${HOME}/.aws:/root/.aws" \
# 		--log-driver none \
# 		--name aws \
# 		${DOCKER_REPO_PREFIX}/awscli "$@"
# }
az(){
	docker run -it --rm \
		-v "${HOME}/.azure:/root/.azure" \
		--log-driver none \
		${DOCKER_REPO_PREFIX}/azure-cli "$@"
}
bees(){
	docker run -it --rm \
		-e NOTARY_TOKEN \
		-v "${HOME}/.bees:/root/.bees" \
		-v "${HOME}/.boto:/root/.boto" \
		-v "${HOME}/.dev:/root/.ssh:ro" \
		--log-driver none \
		--name bees \
		${DOCKER_REPO_PREFIX}/beeswithmachineguns "$@"
}
cadvisor(){
	docker run -d \
		--restart always \
		-v /:/rootfs:ro \
		-v /var/run:/var/run:rw \
		-v /sys:/sys:ro  \
		-v /var/lib/docker/:/var/lib/docker:ro \
		-p 1234:8080 \
		--name cadvisor \
		google/cadvisor

	hostess add cadvisor "$(docker inspect --format '{{.NetworkSettings.Networks.bridge.IPAddress}}' cadvisor)"
	browser-exec "http://cadvisor:8080"
}
cheese(){
	del_stopped cheese

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-v "${HOME}/Pictures:/root/Pictures" \
		--device /dev/video0 \
		--device /dev/snd \
		--device /dev/dri \
		--name cheese \
		${DOCKER_REPO_PREFIX}/cheese
}
chrome(){
	# add flags for proxy if passed
	local proxy=
	local map
	local args=$*
	if [[ "$1" == "tor" ]]; then
		relies_on torproxy

		map="MAP * ~NOTFOUND , EXCLUDE torproxy"
		proxy="socks5://torproxy:9050"
		args="https://check.torproject.org/api/ip ${*:2}"
	fi

	del_stopped chrome

	# one day remove /etc/hosts bind mount when effing
	# overlay support inotify, such bullshit
	docker run -d \
		--memory 3gb \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-v "${HOME}/Downloads:/root/Downloads" \
		-v "${HOME}/Pictures:/root/Pictures" \
		-v "${HOME}/Torrents:/root/Torrents" \
		-v "${HOME}/.chrome:/data" \
		-v /dev/shm:/dev/shm \
		-v /etc/hosts:/etc/hosts \
		--security-opt seccomp:/etc/docker/seccomp/chrome.json \
		--device /dev/snd \
		--device /dev/dri \
		--device /dev/video0 \
		--device /dev/usb \
		--device /dev/bus/usb \
		--group-add audio \
		--group-add video \
		--name chrome \
		${DOCKER_REPO_PREFIX}/chrome --user-data-dir=/data \
		--proxy-server="$proxy" \
		--host-resolver-rules="$map" "$args"

}
consul(){
	del_stopped consul

	# check if we passed args and if consul is running
	local state
	state=$(docker inspect --format "{{.State.Running}}" consul 2>/dev/null)
	if [[ "$state" == "true" ]] && [[ "$*" != "" ]]; then
		docker exec -it consul consul "$@"
		return 0
	fi

		# -v "${HOME}/.consul:/etc/consul.d" \
		# ${DOCKER_REPO_PREFIX}/consul agent \
		# ${DOCKER_REPO_PREFIX}/consul agent -dev \
		# ${DOCKER_REPO_PREFIX}/consul "$@" \
		# hashicorp/consul-k8s "$@" \
		# docker run  --name consul "registry.hub.docker.com/hashicorp/consul-k8s:0.7.0" consul-k8s agent --dev -config-dir /etc/consul.d && docker rm consul

		# docker run  --name consul "registry.hub.docker.com/hashicorp/consul-k8s:0.7.0" consul-k8s --help && docker rm consul
		# "registry.hub.docker.com/hashicorp/consul-k8s:0.7.0" "$@"
		# "registry.hub.docker.com/hashicorp/consul:1.44" "$@" -config-dir /etc/consul.d \
		# -bootstrap-expect "$(1)" \
# 		╰─ sockaddr eval GetPrivateIP
# 192.168.50.218# "index.docker.io/consul" agent -dev -bootstrap-expect "1" -bind "192.168.50.218" -config-dir '/etc/consul.d' -data-dir '/data' -encrypt "$(docker run --rm ${DOCKER_REPO_PREFIX}/consul keygen)" -ui-dir '/usr/src/consul' -server -datacenter "neverland"

# LAN_IP_ADDRESS
# -bind='{{ GetInterfaceIP "eth0" }}'
# -bind='{{ GetAllInterfaces | include "network" "10.99.0.0/24" }}'
# -bind='{{ GetDefaultInterfaces | include "network" "10.99.0.0/24" | sort "size,address" | attr "address" }}'
# -bind='{{ GetAllInterfaces | exclude "rfc" "6890" | sort "type,size,address" | include "flags" "up|forwardable" | attr "address" }}'
	# sudo hostess add consul "$(docker inspect --format '{{.NetworkSettings.Networks.bridge.IPAddress}}' consul)"

# ╰─ {{ GetPrivateIP }}
	# docker rm consul --force &&
	docker run -d \
		--restart always \
		-v "/data/.consul:/etc/consul.d" \
		-v "/data/.consul:/consul/data" \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-p 8500:8500 \
		-e GOMAXPROCS=2 \
		--name consul -h consul \
		"index.docker.io/consul" agent -dev -node="consul" -join '{{ GetInterfaceIP "eth0" }}' -config-dir '/etc/consul.d' -data-dir '/consul/data' -client='{{ GetInterfaceIP "eth0" }}' -bind='{{ GetPrivateIP }}' -ui -server -datacenter "neverland"
		# --net host \
	sudo hostess add consul $(docker inspect --format '{{.NetworkSettings.Networks.bridge.IPAddress}}' consul)
	# sudo hostess add consul "$docker inspect --format {{ GetPrivateIP }} consul"
	# sudo hostess add consul "$docker inspect --format '{{.Config.Hostname}}' consul"
	browser-exec "http://consul:8500"
	# -bootstrap-expect "3"
		# "index.docker.io/consul" agent -dev -bootstrap-expect "1" -bind='{{ GetPrivateIP }}' -config-dir '/etc/consul.d' -data-dir '/consul/data' -client='{{ GetInterfaceIP "eth0" }}' -bind='{{ GetInterfaceIP "eth0" }}' -bootstrap-expect=3 -encrypt "$(docker run --rm ${DOCKER_REPO_PREFIX}/consul keygen)" -client=0.0.0.0 -ui -server -datacenter "neverland"
}
dcos(){
	docker run -it --rm \
		-v "${HOME}/.dcos:/root/.dcos" \
		-v "$(pwd):/root/apps" \
		-w /root/apps \
		${DOCKER_REPO_PREFIX}/dcos-cli "$@"
}
firefox(){
	del_stopped firefox

	docker run -d \
		--memory 2gb \
		--net host \
		--cpuset-cpus 0 \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v "${HOME}/.firefox/cache:/root/.cache/mozilla" \
		-v "${HOME}/.firefox/mozilla:/root/.mozilla" \
		-v "${HOME}/Downloads:/root/Downloads" \
		-v "${HOME}/Pictures:/root/Pictures" \
		-v "${HOME}/Torrents:/root/Torrents" \
		-e "DISPLAY=unix${DISPLAY}" \
		-e GDK_SCALE \
		-e GDK_DPI_SCALE \
		--device /dev/snd \
		--device /dev/dri \
		--name firefox \
		${DOCKER_REPO_PREFIX}/firefox "$@"

	# exit current shell
	exit 0
}
fleetctl(){
	docker run --rm -it \
		--entrypoint fleetctl \
		-v "${HOME}/.fleet://.fleet" \
		r.j3ss.co/fleet "$@"
}
gcalcli(){
	docker run --rm -it \
		-v /etc/localtime:/etc/localtime:ro \
		-v "${HOME}/.gcalcli/home:/home/gcalcli/home" \
		-v "${HOME}/.gcalcli/work/oauth:/home/gcalcli/.gcalcli_oauth" \
		-v "${HOME}/.gcalcli/work/gcalclirc:/home/gcalcli/.gcalclirc" \
		--name gcalcli \
		${DOCKER_REPO_PREFIX}/gcalcli "$@"
}
dgcloud(){
	docker run --rm -it \
		-v "${HOME}/.gcloud:/root/.config/gcloud" \
		-v "${HOME}/.ssh:/root/.ssh:ro" \
		-v "$(which docker):/usr/bin/docker" \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--name gcloud \
		${DOCKER_REPO_PREFIX}/gcloud "$@"
}
gimp(){
	del_stopped gimp

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-v "${HOME}/Pictures:/root/Pictures" \
		-v "${HOME}/.gtkrc:/root/.gtkrc" \
		-e GDK_SCALE \
		-e GDK_DPI_SCALE \
		--name gimp \
		${DOCKER_REPO_PREFIX}/gimp
}
gitsome(){
	docker run --rm -it \
		-v /etc/localtime:/etc/localtime:ro \
		--name gitsome \
		--hostname gitsome \
		-v "${HOME}/.gitsomeconfig:/home/anon/.gitsomeconfig" \
		-v "${HOME}/.gitsomeconfigurl:/home/anon/.gitsomeconfigurl" \
		${DOCKER_REPO_PREFIX}/gitsome
}
hollywood(){
	docker run --rm -it \
		--name hollywood \
		${DOCKER_REPO_PREFIX}/hollywood
}
htop(){
	docker run --rm -it \
		--pid host \
		--net none \
		--name htop \
		${DOCKER_REPO_PREFIX}/htop
}
htpasswd(){
	docker run --rm -it \
		--net none \
		--name htpasswd \
		--log-driver none \
		${DOCKER_REPO_PREFIX}/htpasswd "$@"
}
# http(){
# 	docker run -t --rm \
# 		-v /var/run/docker.sock:/var/run/docker.sock \
# 		--log-driver none \
# 		${DOCKER_REPO_PREFIX}/httpie "$@"
# }
imagemin(){
	local image=$1
	local extension="${image##*.}"
	local filename="${image%.*}"

	docker run --rm -it \
		-v /etc/localtime:/etc/localtime:ro \
		-v "${HOME}/Pictures:/root/Pictures" \
		${DOCKER_REPO_PREFIX}/imagemin sh -c "imagemin /root/Pictures/${image} > /root/Pictures/${filename}_min.${extension}"
}
irssi() {
	del_stopped irssi
	# relies_on notify_osd

	docker run --rm -it \
		--user root \
		-v "${HOME}/.irssi:/home/user/.irssi" \
		${DOCKER_REPO_PREFIX}/irssi \
		chown -R user /home/user/.irssi

	docker run --rm -it \
		-v /etc/localtime:/etc/localtime:ro \
		-v "${HOME}/.irssi:/home/user/.irssi" \
		--read-only \
		--name irssi \
		${DOCKER_REPO_PREFIX}/irssi
}
john(){
	local file
	file=$(realpath "$1")

	docker run --rm -it \
		-v "${file}:/root/$(basename "${file}")" \
		${DOCKER_REPO_PREFIX}/john "$@"
}
kernel_builder(){
	docker run --rm -it \
		-v /usr/src:/usr/src \
		-v /lib/modules:/lib/modules \
		-v /boot:/boot \
		--name kernel-builder \
		${DOCKER_REPO_PREFIX}/kernel-builder
}
keypassxc(){
	del_stopped keypassxc

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v /usr/share/X11/xkb:/usr/share/X11/xkb:ro \
		-e "DISPLAY=unix${DISPLAY}" \
		-v /etc/machine-id:/etc/machine-id:ro \
		--name keypassxc \
		${DOCKER_REPO_PREFIX}/keepassxc
}
kvm(){
	del_stopped kvm
	relies_on pulseaudio

	# modprobe the module
	modprobe kvm

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v /run/libvirt:/var/run/libvirt \
		-e "DISPLAY=unix${DISPLAY}" \
		--link pulseaudio:pulseaudio \
		-e PULSE_SERVER=pulseaudio \
		--group-add audio \
		--name kvm \
		--privileged \
		${DOCKER_REPO_PREFIX}/kvm
}
libreoffice(){
	del_stopped libreoffice

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-v "${HOME}/slides:/root/slides" \
		-e GDK_SCALE \
		-e GDK_DPI_SCALE \
		--name libreoffice \
		${DOCKER_REPO_PREFIX}/libreoffice
}
lpass(){
	docker run --rm -it \
		-v "${HOME}/.lpass:/root/.lpass" \
		--name lpass \
		${DOCKER_REPO_PREFIX}/lpass "$@"
}
lynx(){
	docker run --rm -it \
		--name lynx \
		${DOCKER_REPO_PREFIX}/lynx "$@"
}
masscan(){
	docker run -it --rm \
		--log-driver none \
		--net host \
		--cap-add NET_ADMIN \
		--name masscan \
		${DOCKER_REPO_PREFIX}/masscan "$@"
}
mc(){
	cwd="$(pwd)"
	name="$(basename "$cwd")"

	docker run --rm -it \
		--log-driver none \
		-v "${cwd}:/home/mc/${name}" \
		--workdir "/home/mc/${name}" \
		${DOCKER_REPO_PREFIX}/mc "$@"
}
mpd(){
	del_stopped mpd

	# adding cap sys_admin so I can use nfs mount
	# the container runs as a unpriviledged user mpd
	docker run -d \
		--device /dev/snd \
		--cap-add SYS_ADMIN \
		-e MPD_HOST=/var/lib/mpd/socket \
		-v /etc/localtime:/etc/localtime:ro \
		-v /etc/exports:/etc/exports:ro \
		-v "${HOME}/.mpd:/var/lib/mpd" \
		-v "${HOME}/.mpd.conf:/etc/mpd.conf" \
		--name mpd \
		${DOCKER_REPO_PREFIX}/mpd
}
mutt(){
	# subshell so we dont overwrite variables
	(
	local account=$1
	export IMAP_SERVER
	export SMTP_SERVER

	if [[ "$account" == "riseup" ]]; then
		export GMAIL=$MAIL_RISEUP
		export GMAIL_NAME=$MAIL_RISEUP_NAME
		export GMAIL_PASS=$MAIL_RISEUP_PASS
		export GMAIL_FROM=$MAIL_RISEUP_FROM
		IMAP_SERVER=mail.riseup.net
		SMTP_SERVER=$IMAP_SERVER
	fi

	docker run -it --rm \
		-e GMAIL \
		-e GMAIL_NAME \
		-e GMAIL_PASS \
		-e GMAIL_FROM \
		-e GPG_ID \
		-e IMAP_SERVER \
		-e SMTP_SERVER \
		-v "${HOME}/.gnupg:/home/user/.gnupg:ro" \
		-v /etc/localtime:/etc/localtime:ro \
		--name "mutt-${account}" \
		${DOCKER_REPO_PREFIX}/mutt
	)
}
ncmpc(){
	del_stopped ncmpc

	docker run --rm -it \
		-v "${HOME}/.mpd/socket:/var/run/mpd/socket" \
		-e MPD_HOST=/var/run/mpd/socket \
		--name ncmpc \
		${DOCKER_REPO_PREFIX}/ncmpc "$@"
}
neoman(){
	del_stopped neoman

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		--device /dev/bus/usb \
		--device /dev/usb \
		--name neoman \
		${DOCKER_REPO_PREFIX}/neoman
}
nes(){
	del_stopped nes
	local game=$1

	docker run -d \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		--device /dev/dri \
		--device /dev/snd \
		--name nes \
		${DOCKER_REPO_PREFIX}/nes "/games/${game}.rom"
}
netcat(){
	docker run --rm -it \
		--net host \
		${DOCKER_REPO_PREFIX}/netcat "$@"
}

nmap(){
	docker run --rm -it \
		--net host \
		${DOCKER_REPO_PREFIX}/nmap "$@"
}

notify_osd(){
	del_stopped notify_osd

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		--net none \
		-v /etc \
		-v /home/user/.dbus \
		-v /home/user/.cache/dconf \
		-e "DISPLAY=unix${DISPLAY}" \
		--name notify_osd \
		${DOCKER_REPO_PREFIX}/notify-osd
}
alias notify-send=notify_send
notify_send(){
	relies_on notify_osd
	local args=${*:2}
	docker exec -i notify_osd notify-send "$1" "${args}"
}
opensnitch(){
	del_stopped opensnitchd
	del_stopped opensnitch

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		--net host \
		--cap-add NET_ADMIN \
		-v /etc/machine-id:/etc/machine-id:ro \
		-v /var/run/dbus:/var/run/dbus \
		-v /usr/share/dbus-1:/usr/share/dbus-1 \
		-v "/var/run/user/$(id -u):/var/run/user/$(id -u)" \
		-e DBUS_SESSION_BUS_ADDRESS \
		-e XAUTHORITY \
		-v "${HOME}/.Xauthority:$HOME/.Xauthority" \
		-v /tmp:/tmp \
		--name opensnitchd \
		${DOCKER_REPO_PREFIX}/opensnitchd

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-v /usr/share/X11:/usr/share/X11:ro \
		-v /usr/share/dbus-1:/usr/share/dbus-1 \
		-v /etc/machine-id:/etc/machine-id:ro \
		-v /var/run/dbus:/var/run/dbus \
		-v "/var/run/user/$(id -u):/var/run/user/$(id -u)" \
		-e DBUS_SESSION_BUS_ADDRESS \
		-e XAUTHORITY \
		-v "${HOME}/.Xauthority:$HOME/.Xauthority" \
		-e HOME \
		-e QT_DEVICE_PIXEL_RATIO \
		-e XDG_RUNTIME_DIR \
		-v /etc/passwd:/etc/passwd:ro \
		-v /etc/group:/etc/group:ro \
		-v /tmp:/tmp \
		-u "$(id -u)" -w "$HOME" \
		--net host \
		--name opensnitch \
		${DOCKER_REPO_PREFIX}/opensnitch
}
pandoc(){
	local file=${*: -1}
	local lfile
	lfile=$(readlink -m "$(pwd)/${file}")
	local rfile
	rfile=$(readlink -m "/$(basename "$file")")
	local args=${*:1:${#@}-1}

	docker run --rm \
		-v "${lfile}:${rfile}" \
		-v /tmp:/tmp \
		--name pandoc \
		${DOCKER_REPO_PREFIX}/pandoc "${args}" "${rfile}"
}
pivman(){
	del_stopped pivman

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		--device /dev/bus/usb \
		--device /dev/usb \
		--name pivman \
		${DOCKER_REPO_PREFIX}/pivman
}
pms(){
	del_stopped pms

	docker run --rm -it \
		-v "${HOME}/.mpd/socket:/var/run/mpd/socket" \
		-e MPD_HOST=/var/run/mpd/socket \
		--name pms \
		${DOCKER_REPO_PREFIX}/pms "$@"
}
pond(){
	del_stopped pond
	relies_on torproxy

	docker run --rm -it \
		--net container:torproxy \
		--name pond \
		${DOCKER_REPO_PREFIX}/pond
}
privoxy(){
	del_stopped privoxy
	relies_on torproxy

	docker run -d \
		--restart always \
		--link torproxy:torproxy \
		-v /etc/localtime:/etc/localtime:ro \
		-p 8118:8118 \
		--name privoxy \
		${DOCKER_REPO_PREFIX}/privoxy

	hostess add privoxy "$(docker inspect --format '{{.NetworkSettings.Networks.bridge.IPAddress}}' privoxy)"
}
pulseaudio(){
	del_stopped pulseaudio

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		--device /dev/snd \
		-p 4713:4713 \
		--restart always \
		--group-add audio \
		--name pulseaudio \
		${DOCKER_REPO_PREFIX}/pulseaudio
}
rainbowstream(){
	docker run -it --rm \
		-v /etc/localtime:/etc/localtime:ro \
		-v "${HOME}/.rainbow_oauth:/root/.rainbow_oauth" \
		-v "${HOME}/.rainbow_config.json:/root/.rainbow_config.json" \
		--name rainbowstream \
		${DOCKER_REPO_PREFIX}/rainbowstream
}
registrator(){
	del_stopped registrator

	docker run -d --restart always \
		-v /var/run/docker.sock:/tmp/docker.sock \
		--net host \
		--name registrator \
		gliderlabs/registrator consul:
}
remmina(){
	del_stopped remmina

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-e GDK_SCALE \
		-e GDK_DPI_SCALE \
		-v "${HOME}/.remmina:/root/.remmina" \
		--name remmina \
		--net host \
		${DOCKER_REPO_PREFIX}/remmina
}
ricochet(){
	del_stopped ricochet

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-e GDK_SCALE \
		-e GDK_DPI_SCALE \
		-e QT_DEVICE_PIXEL_RATIO \
		--device /dev/dri \
		--name ricochet \
		${DOCKER_REPO_PREFIX}/ricochet
}
rstudio(){
	del_stopped rstudio

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v "${HOME}/fastly-logs:/root/fastly-logs" \
		-v /dev/shm:/dev/shm \
		-e "DISPLAY=unix${DISPLAY}" \
		-e QT_DEVICE_PIXEL_RATIO \
		--device /dev/dri \
		--name rstudio \
		${DOCKER_REPO_PREFIX}/rstudio
}
s3cmdocker(){
	del_stopped s3cmd

	docker run --rm -it \
		-e AWS_ACCESS_KEY="${DOCKER_AWS_ACCESS_KEY}" \
		-e AWS_SECRET_KEY="${DOCKER_AWS_ACCESS_SECRET}" \
		-v "$(pwd):/root/s3cmd-workspace" \
		--name s3cmd \
		${DOCKER_REPO_PREFIX}/s3cmd "$@"
}
scudcloud(){
	del_stopped scudcloud

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-v /etc/machine-id:/etc/machine-id:ro \
		-v /var/run/dbus:/var/run/dbus \
		-v "/var/run/user/$(id -u):/var/run/user/$(id -u)" \
		-e TERM \
		-e XAUTHORITY \
		-e DBUS_SESSION_BUS_ADDRESS \
		-e HOME \
		-e QT_DEVICE_PIXEL_RATIO \
		-v /etc/passwd:/etc/passwd:ro \
		-v /etc/group:/etc/group:ro \
		-u "$(whoami)" -w "$HOME" \
		-v "${HOME}/.Xauthority:$HOME/.Xauthority" \
		-v "${HOME}/.scudcloud:/home/jessie/.config/scudcloud" \
		--device /dev/snd \
		--name scudcloud \
		${DOCKER_REPO_PREFIX}/scudcloud

	# exit current shell
	exit 0
}
shorewall(){
	del_stopped shorewall

	docker run --rm -it \
		--net host \
		--cap-add NET_ADMIN \
		--privileged \
		--name shorewall \
		${DOCKER_REPO_PREFIX}/shorewall "$@"
}
skype(){
	del_stopped skype
	relies_on pulseaudio

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		--link pulseaudio:pulseaudio \
		-e PULSE_SERVER=pulseaudio \
		--security-opt seccomp:unconfined \
		--device /dev/video0 \
		--group-add video \
		--group-add audio \
		--name skype \
		${DOCKER_REPO_PREFIX}/skype
}
slack(){
	del_stopped slack

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		--device /dev/snd \
		--device /dev/dri \
		--device /dev/video0 \
		--group-add audio \
		--group-add video \
		-v "${HOME}/.slack:/root/.config/Slack" \
		--ipc="host" \
		--name slack \
		${DOCKER_REPO_PREFIX}/slack "$@"
}
spotify(){
	del_stopped spotify

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-e QT_DEVICE_PIXEL_RATIO \
		--security-opt seccomp:unconfined \
		--device /dev/snd \
		--device /dev/dri \
		--group-add audio \
		--group-add video \
		--name spotify \
		${DOCKER_REPO_PREFIX}/spotify
}


# sqlcmd -S <ip_address>,1433 -U SA -P "<YourNewStrong@Passw0rd>"

ssh2john(){
	local file
	file=$(realpath "$1")

	docker run --rm -it \
		-v "${file}:/root/$(basename "${file}")" \
		--entrypoint ssh2john \
		${DOCKER_REPO_PREFIX}/john "$@"
}

sshb0t(){
	del_stopped sshb0t

	if [[ ! -d "${HOME}/.ssh" ]]; then
		mkdir -p "${HOME}/.ssh"
	fi

	if [[ ! -f "${HOME}/.ssh/authorized_keys" ]]; then
		touch "${HOME}/.ssh/authorized_keys"
	fi

	GITHUB_USER=${GITHUB_USER:=jessfraz}

	docker run --rm -it \
		--name sshb0t \
		-v "${HOME}/.ssh/authorized_keys:/root/.ssh/authorized_keys" \
		r.j3ss.co/sshb0t \
		--user "${GITHUB_USER}" --keyfile /root/.ssh/authorized_keys --once
}

steam(){
	del_stopped steam
	relies_on pulseaudio

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /etc/machine-id:/etc/machine-id:ro \
		-v /var/run/dbus:/var/run/dbus \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v "${HOME}/.steam:/home/steam" \
		-e "DISPLAY=unix${DISPLAY}" \
		--link pulseaudio:pulseaudio \
		-e PULSE_SERVER=pulseaudio \
		--device /dev/dri \
		--name steam \
		${DOCKER_REPO_PREFIX}/steam
}

# t(){
# 	docker run -t --rm \
# 		-v "${HOME}/.trc:/root/.trc" \
# 		--log-driver none \
# 		${DOCKER_REPO_PREFIX}/t "$@"
# }

tarsnap(){
	docker run --rm -it \
		-v "${HOME}/.tarsnaprc:/root/.tarsnaprc" \
		-v "${HOME}/.tarsnap:/root/.tarsnap" \
		-v "$HOME:/root/workdir" \
		${DOCKER_REPO_PREFIX}/tarsnap "$@"
}

#telnet(){
#	docker run -it --rm \
#		--log-driver none \
#		${DOCKER_REPO_PREFIX}/telnet "$@"
#}

termboy(){
	del_stopped termboy
	local game=$1

	docker run --rm -it \
		--device /dev/snd \
		--name termboy \
		${DOCKER_REPO_PREFIX}/nes "/games/${game}.rom"
}

# terraform(){
# 	docker run -it --rm \
# 		-v "${HOME}:${HOME}:ro" \
# 		-v "$(pwd):/usr/src/repo" \
# 		-v /tmp:/tmp \
# 		--workdir /usr/src/repo \
# 		--log-driver none \
# 		-e GOOGLE_APPLICATION_CREDENTIALS \
# 		-e SSH_AUTH_SOCK \
# 		${DOCKER_REPO_PREFIX}/terraform "$@"
# }

tor(){
	del_stopped tor

	docker run -d \
		--net host \
		--name tor \
		${DOCKER_REPO_PREFIX}/tor

	# set up the redirect iptables rules
	sudo setup-tor-iptables

	# validate we are running through tor
	browser-exec "https://check.torproject.org/"
}

torbrowser(){
	del_stopped torbrowser

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-e GDK_SCALE \
		-e GDK_DPI_SCALE \
		--device /dev/snd \
		--name torbrowser \
		${DOCKER_REPO_PREFIX}/tor-browser

	# exit current shell
	exit 0
}

tormessenger(){
	del_stopped tormessenger

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-e GDK_SCALE \
		-e GDK_DPI_SCALE \
		--device /dev/snd \
		--name tormessenger \
		${DOCKER_REPO_PREFIX}/tor-messenger

	# exit current shell
	exit 0
}

torproxy(){
	del_stopped torproxy

	docker run -d \
		--restart always \
		-v /etc/localtime:/etc/localtime:ro \
		-p 9050:9050 \
		--name torproxy \
		${DOCKER_REPO_PREFIX}/tor-proxy

	hostess add torproxy "$(docker inspect --format '{{.NetworkSettings.Networks.bridge.IPAddress}}' torproxy)"
}

traceroute(){
	docker run --rm -it \
		--net host \
		${DOCKER_REPO_PREFIX}/traceroute "$@"
}

transmission(){
	del_stopped transmission

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v "${HOME}/Torrents:/transmission/download" \
		-v "${HOME}/.transmission:/transmission/config" \
		-p 9091:9091 \
		-p 51413:51413 \
		-p 51413:51413/udp \
		--name transmission \
		${DOCKER_REPO_PREFIX}/transmission


	hostess add transmission $(docker inspect --format '{{.NetworkSettings.Networks.bridge.IPAddress}}' transmission)
	browser-exec "http://transmission:9091"
}

# -v "${HOME}/.travis:/root/.travis" \
# -v "$(pwd):/usr/src/repo:ro" \
# travis(){
# 		# -v "/tmp/:/usr/src/repo:ro" \
# 	docker run -it --rm \
# 		-v "/tmp/.travis:/root/.travis" \
# 		-v "$(pwd):/usr/src/repo:rw" \
# 		--workdir /usr/src/repo \
# 		--log-driver none \
# 		${DOCKER_REPO_PREFIX}/travis "$@"
# }

virsh(){
	relies_on kvm

	docker run -it --rm \
		-v /etc/localtime:/etc/localtime:ro \
		-v /run/libvirt:/var/run/libvirt \
		--log-driver none \
		--net container:kvm \
		${DOCKER_REPO_PREFIX}/libvirt-client "$@"
}

virt_viewer(){
	relies_on kvm

	docker run -it --rm \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix  \
		-e "DISPLAY=unix${DISPLAY}" \
		-v /run/libvirt:/var/run/libvirt \
		-e PULSE_SERVER=pulseaudio \
		--group-add audio \
		--log-driver none \
		--net container:kvm \
		${DOCKER_REPO_PREFIX}/virt-viewer "$@"
}

alias virt-viewer="virt_viewer"
visualstudio(){
	del_stopped visualstudio

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix  \
		-e "DISPLAY=unix${DISPLAY}" \
		--device /dev/dri \
		--name visualstudio \
		${DOCKER_REPO_PREFIX}/vscode
}

alias vscode="visualstudio"
vlc(){
	del_stopped vlc
	relies_on pulseaudio

	docker run -d \
		-v /etc/localtime:/etc/localtime:ro \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-e "DISPLAY=unix${DISPLAY}" \
		-e GDK_SCALE \
		-e GDK_DPI_SCALE \
		-e QT_DEVICE_PIXEL_RATIO \
		--link pulseaudio:pulseaudio \
		-e PULSE_SERVER=pulseaudio \
		--group-add audio \
		--group-add video \
		-v "${HOME}/Torrents:/home/vlc/Torrents" \
		--device /dev/dri \
		--name vlc \
		${DOCKER_REPO_PREFIX}/vlc
}

# $ cat ~/etc/timezone

watchman(){
	mkdir -p ~/etc
	echo "America/New_York" > ~/etc/timezone
	del_stopped watchman
		# -v /etc/localtime:/etc/localtime:ro \

	docker run -d \
	    -e TZ=America/Los_Angeles \
		-v "${HOME}/etc/timezone":/etc/localtime:ro \
		-v "${HOME}/Downloads:/root/Downloads" \
		--name watchman \
		${DOCKER_REPO_PREFIX}/watchman --foreground
}
weeslack(){
	del_stopped weeslack

	docker run --rm -it \
		-v /etc/localtime:/etc/localtime:ro \
		-v "${HOME}/.weechat:/home/user/.weechat" \
		--name weeslack \
		${DOCKER_REPO_PREFIX}/wee-slack
}
wg(){
	docker run -i --rm \
		--log-driver none \
		-v /tmp:/tmp \
		--cap-add NET_ADMIN \
		--net host \
		--name wg \
		${DOCKER_REPO_PREFIX}/wg "$@"
}
# wireshark(){
# 	del_stopped wireshark

# 	docker run -d \
# 		-v /etc/localtime:/etc/localtime:ro \
# 		-v /tmp/.X11-unix:/tmp/.X11-unix \
# 		-e "DISPLAY=unix${DISPLAY}" \
# 		--cap-add NET_RAW \
# 		--cap-add NET_ADMIN \
# 		--net host \
# 		--name wireshark \
# 		${DOCKER_REPO_PREFIX}/wireshark
# Install Wireshark.app with Homebrew Cask:
# brew uninstall --force wireshark
# # brew uninstall --force --cask wireshark
# brew install --cask wireshark
# brew install --cask wireshark
# brew install --cask wireshark-chmodbpf
# sudo mv /usr/local/bin/idl2wrs /usr/local/bin/idl2wrs_bak
# sudo mv /usr/local/bin/capinfos /usr/local/bin/capinfos_bak
# sudo mv /usr/local/bin/mmdbresolve /usr/local/bin/mmdbresolve_bak
# sudo mv /usr/local/bin/randpkt /usr/local/bin/randpkt_bak
# sudo mv  _bak
# }
wrk(){
	docker run -it --rm \
		--log-driver none \
		--name wrk \
		${DOCKER_REPO_PREFIX}/wrk "$@"
}
ykman(){
	del_stopped ykpersonalize

	docker run --rm -it \
		-v /etc/localtime:/etc/localtime:ro \
		--device /dev/usb \
		--device /dev/bus/usb \
		--name ykman \
		${DOCKER_REPO_PREFIX}/ykman bash
}
ykpersonalize(){
	del_stopped ykpersonalize

	docker run --rm -it \
		-v /etc/localtime:/etc/localtime:ro \
		--device /dev/usb \
		--device /dev/bus/usb \
		--name ykpersonalize \
		${DOCKER_REPO_PREFIX}/ykpersonalize bash
}
yubico_piv_tool(){
	del_stopped yubico-piv-tool

	docker run --rm -it \
		-v /etc/localtime:/etc/localtime:ro \
		--device /dev/usb \
		--device /dev/bus/usb \
		--name yubico-piv-tool \
		${DOCKER_REPO_PREFIX}/yubico-piv-tool bash
}
alias yubico-piv-tool="yubico_piv_tool"

# ENV TZ=America/Los_Angeles
# RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
# avoid error with timezone
#https://github.com/spotify/docker-maven-plugin
# https://serverfault.com/questions/683605/docker-container-time-timezone-will-not-reflect-changes
	    # -v /etc/localtime:/etc/localtime:ro \
#source ~/.dockerfunc && maven_tool clean -DprojectID=sap-fgl-techops-dev package
# docker volume create --name maven-repo
# docker run -it -v maven-repo:/root/.m2 maven mvn archetype:generate # will download artifacts
# docker run -it -v maven-repo:/root/.m2 maven mvn archetype:generate # will reuse downloaded artifacts
# Or you can just use your home .m2 cache directory that you share e.g. with your Eclipse/IDEA:

# docker run -it --rm -v "$PWD":/usr/src/mymaven -v "$HOME/.m2":/root/.m2 -v "$PWD/target:/usr/src/mymaven/target" -w /usr/src/mymaven maven mvn clean package
maven_tool(){
	del_stopped maven_tool
	docker run --rm -it \
	    -e TZ=America/Los_Angeles \
		-v "$PWD":/usr/src/mymaven -v "$HOME/.m2":/root/.m2 \
		-w /usr/src/mymaven \
		--name maven_tool \
		maven:latest "$@"
		# -v "$PWD/target:/usr/src/mymaven/target" \
		# -v "$(pwd)":/usr/src/mymaven \
		# -v ${HOME}/.m2:/root/.m2 \
		# -v "$PWD/target:/usr/src/mymaven/target" \
		# fabric8/maven-builder:latest "$@"
		# -v "${cwd}:/usr/src/${name}" \
		# -v "${cwd}:/home/mc/${name}" \
		# --workdir "/home/mc/${name}
}

#docker run -it -v ~/.kube:/root/.kube dtzar/helm-kubectl
# -v ~/.kube:/root/.kube

tiller_tool_dev() {
	# Working local usage of tiller. Stores release info in a secret. Tiller does not
	# Get installed into the cluster
	export HELM_HOME=/root/.helm
	export HELM_HOST=localhost:44134
	export GOOGLE_APPLICATION_CREDENTIALS=/var/run/secret/ds-svc-builder.json
	export CLOUDSDK_COMPUTE_REGION=northamerica-northeast1-a
	export CLOUDSDK_COMPUTE_ZONE=northamerica-northeast1-a
	export CLOUDSDK_CONTAINER_CLUSTER=runner-argo-cluster
	export PROJECT_ID=sap-fgl-techops-dev-186612

	# Kubectl config file created and configured
	export TILLER_NAMESPACE=argo
	export HELM_HOST=localhost:44134
	tiller --storage=secret
	./bin/tiller --storage=secret --listen=localhost:44134
	tiller --storage=secret
	helm install --name consulrev1 stable/consul --namespace argo

	docker run --rm -it \
		-e TILLERLESS=${TILLERLESS} \
		-e HELM_HOME=${HELM_HOME} \
		-e HELM_HOST=${HELM_HOST} \
		-e GOOGLE_APPLICATION_CREDENTIALS=${GOOGLE_APPLICATION_CREDENTIALS} \
		-e PROJECT_ID=${PROJECT_ID} \
		-e CLOUDSDK_COMPUTE_REGION=${CLOUDSDK_COMPUTE_REGION} \
		-e CLOUDSDK_COMPUTE_ZONE=${CLOUDSDK_COMPUTE_ZONE} \
		-e CLOUDSDK_CONTAINER_CLUSTER=${CLOUDSDK_CONTAINER_CLUSTER} \
		-v "$PWD"/secret:/var/run/secret \
		--entrypoint "/bin/sh" \
		--name gcloud gcr.io/cloud-builders/gcloud
		# --name tillerless gcr.io/sap-fgl-techops-dev-186612/helm

	# # Helm dev
	# ln -s ${HOME}/.helm/plugins/helm-tiller/bin/tiller /usr/local/bin/tiller
	# helm init;
	# helm init --upgrade;
	# helm repo update;
	# helm tiller install --name my-release stable/consul
	# helm tiller install my-release stable/consul argo --set=rbac.create=false
	# helm install --name myrelease stable/consul --namespace argo
	# #notes
	# ./bin/tiller --storage=secret --listen=localhost:44134  (wd: ~/.helm/plugins/helm-tiller
}

# Buildctl in a docker image
build_tool() {
	del_stopped build_tool

	docker run -d --privileged \
	  -p 1234:1234 \
	  --name build_tool \
	  tonistiigi/buildkit --addr tcp://0.0.0.0:1234
	export BUILDKIT_HOST=tcp://0.0.0.0:1234
	buildctl build --help

	# 	Opentracing support
	# BuildKit supports opentracing for buildkitd gRPC API and buildctl commands. To capture the trace to Jaeger, set JAEGER_TRACE environment variable to the collection address.

	# docker run -d -p6831:6831/udp -p16686:16686 jaegertracing/all-in-one:latest
	# export JAEGER_TRACE=0.0.0.0:6831
	# # restart buildkitd and buildctl so they know JAEGER_TRACE
	# # any buildctl command should be traced to http://127.0.0.1:16686/

	# Also
	#https://github.com/ehazlett/.dotfiles/blob/master/bashrc
# 	buildkit-build() {
#     IMG=$1
#     if [ -z "$IMG" ]; then
#         echo "Usage: buikdkit-build <name>"
#         return
#     fi
#     sudo buildctl build --frontend=dockerfile.v0 --local context=. --local dockerfile=. --exporter=image --exporter-opt name=$IMG
# }
}

# func goworkhere_tool() {
goworkhere_tool() {
    # NAME=$1
    # export GOPATH=~/go/$NAME
    export GOPATH=${PWD}:$GOPATH
    # export PATH=$PATH:$GOPATH/bin
    # export PROJECT=$NAME
    # mkdir -p $GOPATH/{src,bin}
    echo "Go env setup: $GOPATH"
    # cd $GOPATH
    # set_title $NAME
}

# func godev_tool() {
godev_tool() {
    NAME=$1
    export GOPATH=~/go/$NAME
    export PATH=$PATH:$GOPATH/bin
    export PROJECT=$NAME
    mkdir -p $GOPATH/{src,bin}
    echo "Go env setup: $GOPATH"
    cd $GOPATH
    # set_title $NAME
}

# ehazlett
macdev() {
    CMD=${2:-/bin/bash}
    set_title "dev : $1"
    local name=dev-$1
    docker inspect $name > /dev/null 2>&1
    if [ $? = 0 ]; then
        docker attach $name
    else
        docker run -ti --restart=always \
            -e PROJECT=$1 \
            --net=host \
            --name=$name \
            -v $HOME/.vim:/home/ehazlett/.vim \
            -v $HOME/.vimrc:/home/ehazlett/.vimrc \
            -v $HOME/.bashrc:/home/ehazlett/.bashrc \
            -v $HOME/.ssh/config:/home/ehazlett/.ssh/config \
            -v ~/Sync:/home/ehazlett/Sync \
            -v ~/.docker:/home/ehazlett/.docker \
            -v /var/run/docker.sock:/var/run/docker.sock \
            --group-add staff \
            ehazlett/devbox $CMD
    fi
}

# Visualize stacks of terraform code
radius_tool() {
	docker run --cap-add=SYS_ADMIN -it --rm \
	  -p 5000:5000 \
	  -v $(pwd):/workdir:ro \
	  28mm/blast-radius \
	  --serve "$@"
	  #compute/storage/build
}

# Development
gnatsd_tool() {
	del_stopped gnatsd_tool
	# -v /etc/localtime:/etc/localtime:ro \
	echo "[Client]\t\t[Monitor]\t\t[][]\nPorts -p 4222:4222 -p 8222:8222 -p 6222:6222"
	docker run --rm -p 4222:4222 -p 8222:8222 -p 6222:6222 --name gnatsd -ti nats:latest
	# docker run -p 4222:4222 -p 8222:8222 -p 6222:6222 --name gnatsd -ti nats:latest
}

nats_streaming_tool() {
    docker run --rm -p 4223:4223 -p 8223:8223 --name nats-streaming -ti nats-streaming:latest
}

mssql_tools(){
	echo "$(tput setaf 6)mac ensure docker host is passed into mssql tools$(tput sgr0)"
	echo "$(tput setaf 6)sudo ifconfig lo0 alias 10.200.10.1/24  # (where 10.200.10.1 is some unused IP address)$(tput sgr0)"
	echo "$(tput setaf 6)export DOCKER_HOST_IP=10.200.10.1$(tput sgr0)"
    docker run -it --name mssql mcr.microsoft.com/mssql-tools \
      /opt/mssql-tools/bin/sqlcmd "$@"

	# example /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P 'n3w5q7!!' -q 'select @@version'
}


############################ Kubernetes Aliases
# kexport_tool() {
#     echo "Exporting resources in namespace"
#     for n in $(kubectl get -o=name pvc,configmap,serviceaccount,secret,ingress,service,deployment,statefulset,hpa,job,cronjob)
# do
#     mkdir -p $(dirname $n)
#     kubectl get -o=yaml --export $n > $n.yaml
# done

# }

# docker_volume_tool_view() {
# 	docker run --rm -it -v /:/vm-root alpine:edge ls -l /vm-root
# }


# docker_volume_tool_view() {
# 	docker run --rm -it -v /:/vm-root alpine:edge sh && cd /vm-root
# }
