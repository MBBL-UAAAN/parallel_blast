#!/usr/bin/env bash

database=$1
query=$2
nodes=$3
user=$4

usage="
USAGE:\n\tlaunch_blast <database> <query> <nodes> <user>\n
\t<database>:\tBLAST database version 5\n
\t<query>:\t*.list file obtained from par_split\n
"

# I check if user is defined
[ -z $database  ] && echo "Database name is missing" && echo -e $usage
[ -z $database  ] && exit 1
[ -z $query  ] && echo "Query is missing!" && echo -e $usage && exit 1
[ -z $nodes  ] && echo "Which nodes do you want to use?" && echo -e $usage && exit 1
[ -z $user  ] && echo "Username is missing" && echo -e $usage
[ -z $user  ] && exit 1

parallel --env load_module,shared,shared_db \
	--sshlogin $nodes \
	--transferfile {} \
	--return {.}.blast \
	--cleanup \
	-a $query \
	"load_module parallel_blast/scripts; \
	load_module ncbi-blast/2.13.0+/bin; \
	wc -l {}; \
	blastn -db $shared_db/random/${database} \
		-query {} \
		-task blastn \
		-out {.}.blast \
		-outfmt 7 \
		-evalue 1000 \
		-gapopen 0 \
		-gapextend 2 \
		-penalty -1 \
		-reward 1"


