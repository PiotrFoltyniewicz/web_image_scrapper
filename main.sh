#!/bin/bash
# Topic 13. Fetching images from a web page. 


#IMPORTANT
# MAKE SURE PARALLEISM WORKS

#limit of parallel downloads
limit=1

downloadFile() {
    echo "Downloading $name"
    curl -o $1 $2
    if [ $? -eq 0 ]
    then
      echo "Downloading finished $name"
    else
      echo "Error. $name not downloaded"
    fi
}

for i in $@
do
  a=$(curl -s $i | tr -s '>' '\n' | grep '<img[^>]*src=".*".*' | sed 's/<img.*src="\([^"]*\)".*/\1/')
  for j in $a
  do
    echo "Found image URL: $j"
    name=$(echo $j | sed "s/.*\/\([^?]*\).*/\1/")
    find $name >/dev/null 2>&1
    if [ $? -eq 0 ]
    then
    echo "Already in the directory: $name"
      continue
    fi
    echo $i $j
    # something wrong here
    j=$(echo $j | sed "s/^\//$i\//")
    echo "TEST $name $j"
    num=$(jobs | wc -l)
    while [ $num -gt $limit ]
    do
      echo "Maximum amount of concurrent downloads achieved. Waiting..."
      sleep 1
    done
    downloadFile $name $j
  done
done
