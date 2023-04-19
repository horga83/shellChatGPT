#!/bin/env ksh

set -f

[[ -n ${1:?markdown file required} ]]

pandoc --standalone --to man "${1}" -o "${1%%?(.1)?(.md)}".1

pandoc --standalone --to html "${1}" -o "${1%%?(.1)?(.md)}".html

pandoc --standalone --to gfm "${1}" -o README.md

#https://eddieantonio.ca/blog/2015/12/18/authoring-manpages-in-markdown-with-pandoc/
#https://jeromebelleman.gitlab.io/posts/publishing/manpages/


##  exit
### Compared md with script help (word by word)
##pandoc --standalone --to plain "${1}" -o plain.txt
##chars="[\]<>_\*\'\"\`\“\”\’"
##a=$(chatgpt.sh -fh)  b=$(sed 's/\xc2\xa0//g' plain.txt)
##vimdiff <(printf '%s\n' ${a//[$chars]})  <(printf '%s\n' ${b//[$chars]})
##rm -- plain.txt

