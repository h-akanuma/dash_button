#!/bin/bash

apt-get update
apt-get upgrade

apt-get install -y git
apt-get install -y libssl-dev libreadline-dev zlib1g-dev
apt-get install -y libpcap-dev
apt-get install -y build-essential
