#!/bin/bash
make && rsync -avz -e ssh site/* aditi.davidad.net:site/ && ssh -t aditi.davidad.net 'cd site; sudo nginx-or -p `pwd`/ -c conf/nginx.conf -s reload'
