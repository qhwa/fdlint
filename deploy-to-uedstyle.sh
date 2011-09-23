#!/bin/bash
git archive --format=tar HEAD --prefix=fdev-xray/ | gzip > xray.tar.gz
scp xray.tar.gz uedstyle@uedstyle:~/
ssh uedstyle@uedstyle "mv fdev-xray fdev-xray-bak && tar -xzf xray.tar.gz && rm -rf fdev-xray-bak"
rm -f xray.tar.gz
