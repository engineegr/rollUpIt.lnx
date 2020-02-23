#! /bin/bash

path="ns.acl.-"
step=0

path_array=()

while IFS= read -r line; do
  path_array+=("$line")
  echo "$line"
done <<<"$(echo $path | sed -E 's/\./\n/g')"

re="/${path_array[0]}:/{h;d}\n"
echo "$re"

step=2
for ((i = 1; i < ${#path_array[@]}; i++)); do
  echo "${path_array[i]}"
  re+="/\s{$step}${path_array[i]}:/{H;x;p;q}\n"
  ((step = step + 2))
done

printf "$re"

sed -n -E "$(printf $re)" "$1"

key="rndc_key"
value="private"
ns_yum_fp="$1"

sed -E "
# h - overwrites the hold space
# d - delete the pattern space until a new line
# then reads the next line to pattern patter and restart
# cycle
# H - appends to hold space
# x - exchange pattern and hold buffer
# p - print pattern space
# q - quit
# g - get from hold space
/^ns:$/{
:check_key
n;
/^\s{2}$key:(.*)/{s/^(\s{2}$key:)(.*)/\1 \"$value\"/;};
b check_key
}" $1
