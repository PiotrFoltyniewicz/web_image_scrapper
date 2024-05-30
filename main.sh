#!/bin/bash
# Topic 13. Fetching images from a web page. 

# limit of parallel downloads
limit=4

downloadFile() {
    echo "Downloading $name"
    curl -so $1 $2
    if [ $? -eq 0 ]
    then
      echo "Download finished $name"
    else
      echo "Error. Image not downloaded"
    fi
}

for i in $@
do
  # check if url is valid
  curl -s $i > /dev/null
  if [ $? -ne 0 ]
  then
    echo "Error when fetching the page: $i"
    continue
  fi
  # fetch image paths from the website
  a=$(curl -s $i | tr -s '>' '\n' | sed -n 's/.*<img[^>]*src="\([^"]*\)".*/\1/p')

  for j in $a
  do
    echo "Found image URL: $j"
    # get name of the img without the path
    name=${j##*/}

    if [ -f "$name" ]
    then
    echo "Already in the directory: $name"
      continue
    fi

    # if path is local then append url at the beggining
    if [ "${j:0:1}" = "/" ]
    then
      j=$(echo "$i$j")
    fi

    # find amount of running processes
    num=$(jobs -rp | wc -l)
    if [ $num -gt $limit ]
    then
      echo "Maximum number of parallel downloads achieved. Waiting..."
    fi
    
    wait -n

    downloadFile $name $j &
  done
done

# wait for downloads to finish
wait
