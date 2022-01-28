#!/bin/bash

attributes="class instance"
sessiondir=~/.i3-sessions
workspaces=$(i3-msg -t get_workspaces | sed -e "s/,/\n/g" | grep name | sed -e "s/\"name\":\"//" | sed -e "s/\"//")
session=$sessiondir/session$2.json

if [[ $1 == "save" ]]; then
	if [[ $2 == "all" ]]; then
		for i in $workspaces; do
			i3-save-tree --workspace=$i > $sessiondir/session$i.json
			for j in $attributes; do
				sed -i "s/\/\/ \"$j\"/\"$j\"/" $sessiondir/session$i.json
			done
		done
	else
		i3-save-tree --workspace=$2 > $session
		for i in $attributes; do
			sed -i "s/\/\/ \"$i\"/\"$i\"/" $session
		done
	fi
elif [[ $1 == "load" ]]; then
	if [[ $2 == "all" ]]; then
		for i in $(ls $sessiondir | sed -e "s/session//" -e "s/.json//"); do
			i3-msg "workspace $i; append_layout $sessiondir/session$1.json"
		done
	else
		i3-msg "workspace $1; append_layout $session"
	fi	
else echo "no matches found"
fi
