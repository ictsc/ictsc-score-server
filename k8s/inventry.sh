#!/bin/sh
if [ -e ./terraform.tfstate ]; then
    ip=`cat terraform.tfstate | jq -r '.outputs[].value' | sed 's/\$/,/'`
    cat << EOS
{
    "cloud_servers"  : [ $ip ]
}
EOS
fi
