#!/bin/sh
set -eu

if [ -e ./terraform.tfstate ]; then
    rm -f hosts
    if [ "`uname`" == "Darwin" ]; then
        ip=`cat terraform.tfstate | jq -r '.outputs[].value' | sed -e 's/\$/,/' | sed -e :loop -e 'N; $!b loop' -e 's/\n/ /g'| sed -e 's/,$//g'`
    else
        # linux style sed
        ip=`cat terraform.tfstate | jq -r '.outputs[].value' | sed -e 's/\$/,/' | sed -e ':loop; N; $!b loop; s/\n/ /g'| sed -e 's/,$//g'`
    fi
    cat << EOS > hosts
{
    "cloud_servers"  : [$ip]
}
EOS
    chmod +x hosts
fi
