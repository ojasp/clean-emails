#!/bin/bash

while (( "$#" )); do

        curl -s --head http://$1/ | head -n 1 | grep "HTTP/1.[01] [23].." > /dev/null
        if [ $? -eq 0 ]; then
              #echo -ne "." #$1 : webpage exists"
                echo -ne ""
        else
                #echo "$1 : Does not Exist" #$1 : unavailable"
                echo $1 >> ./baddomains.txt

        fi

shift

done
