#!/bin/sh

KEY_PATH=${1:?"invalid arguments"}
CERT_PATH=${2:?"invalid arguments"}
kubectl create secret tls contest --key=$KEY_PATH --cert=$CERT_PATH
