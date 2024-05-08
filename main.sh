#!/bin/bash
# Topic 13. Fetching images from a web page. 

# limit of parallel downloads
limit=8

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
  # fetching paths to the images
  a=$(curl -s $i | tr -s '>' '\n' | grep '<img[^>]*src=".*".*' | sed 's/<img.*src="\([^"]*\)".*/\1/')
  if [ $? -ne 0 ]
  then
    echo "Error when fetching the page: $i"
    continue
  fi

  for j in $a
  do
    echo "Found image URL: $j"
    # get name of the img without the path
    name=$(echo $j | sed "s/.*\/\([^?]*\).*/\1/")

    find $name >/dev/null 2>&1
    if [ $? -eq 0 ]
    then
    echo "Already in the directory: $name"
      continue
    fi

    # if path is local then append url at the beggining
    echo $j | grep "^/" > /dev/null
    if [ $? -eq 0 ]
    then
      j=$(echo "$i$j")
    fi

    # find amount of running processes
    num=$(ps -aux | grep "curl" | wc -l)
    if [ $num -gt $limit ]
    then
      echo "Maximum number of parallel downloads achieved. Waiting..."
    fi
    while [ $num -gt $limit ]
    do
      num=$(ps -aux | grep "curl" | wc -l)
    done
    downloadFile $name $j &
  done
done

# wait for all downloads to finish
wait $!
