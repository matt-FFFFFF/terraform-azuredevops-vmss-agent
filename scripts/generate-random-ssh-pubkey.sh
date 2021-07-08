#!/bin/bash

# Source: https://gist.github.com/kraftb/9918106

mkfifo key key.pub && ((cat key > /dev/null; cat key.pub; rm key key.pub)&) && (echo y | ssh-keygen -N '' -q -C 'buildagent@azure' -m PEM -t rsa -b 2048 -f key > /dev/null)
