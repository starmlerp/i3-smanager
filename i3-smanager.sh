#!/bin/bash

attributes=( class instance ) #json attributes we wish to automatically uncomment
blacklist=( 2 3 ) #workspace blacklist: which workspaces to ignore entirely when saving "all" workspaces
sessiondir=~/.i3-sessions
format=$sessiondir/session$2.json

#this is bodgy, and wont work should the guys at i3 decide to change the output
#format of the i3-msg command but it works in this very specific case scenario,
#and i see no much other way to implement it that doesnt involve me developing
#my own text truncating solution
workspaces=$(i3-msg -t get_workspaces | sed -e "s/,/\n/g" | grep name | sed -e "s/\"name\":\"//" | sed -e "s/\"//")

if [[ $1 == "save" ]]; then
	if [[ $2 == "" ]]; then
		for i in $workspaces; do
			for j in ${blacklist[@]}; do
				if [[ $i == $j ]]; then
					continue 2
				fi
			done
			i3-save-tree --workspace=$i > $sessiondir/session$i.json
			for j in ${attributes[@]}; do
				sed -i "s/\/\/ \"$j\"/\"$j\"/" $sessiondir/session$i.json
			done
			sed -E -i "s/(\"${attributes[-1]}\": \".+\"),/\1/" $sessiondir/session$i.json
		done
	else
		i3-save-tree --workspace=$2 > $format
		for i in ${attributes[@]}; do
			sed -i "s/\/\/ \"$i\"/\"$i\"/" $format
			sed -E -i "s/(\"${attributes[-1]}\": \".+\"),/\1/" $format
		done
	fi
elif [[ $1 == "load" ]]; then
	if [[ $2 == "" ]]; then
		for i in $(ls $sessiondir | sed -e "s/session//" -e "s/.json//"); do
			i3-msg "workspace $i; append_layout $sessiondir/session$i.json"
		done
	else
		i3-msg "workspace $2; append_layout $format"
	fi	
else
	echo "no valid arguments passed"
	echo "usage: ${0} load|save [WORKSPACE]"
fi
