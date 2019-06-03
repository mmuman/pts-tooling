#!/bin/sh

cfile="cookies"
tmpfile="tmp"
outfile="data.zip"

if [ "$#" -lt 2 ]; then
	echo "$0 url user [pass]"
	exit 1
fi

cfpurl="$1"
user="$2"
[ "$#" -gt 2 ] && pass="$3" || read pass

# login and get the cookie
curl -c "$cfile" -F "email=$user" -F "password=$pass" -F "signin=1" "$cfpurl" > /dev/null || exit 1

# search for accepted papers
curl -b "$cfile" "${cfpurl}search?q=&t=acc" -o "$tmpfile" || exit 1

posttoken="$(sed -n '/post=/{s/.*post=//;s/\".*//;p;q}' "$tmpfile")"
papers="$(sed -n '/stat_acc/{s/.*data-pid="//;s/".*//;p}' "$tmpfile")"

echo "$posttoken"
echo "$papers"
if [ -z "$papers" ]; then
	echo "no accepted paper found."
	exit 1
fi

for p in $papers; do echo "-F"; echo "pap[]=$p"; done | xargs --verbose curl -v -b "$cfile" -F "defaultact=" -F "forceShow=" -F "fn=get" -F "getfn=jsonattach" -F "tagfn=a" -F "tag=" -F "tagcr_method=schulze" -F "tagcr_source=" -F "assignfn=auto" -F "decision=" -F "recipients=au" "${cfpurl}search?q=&t=acc&post=$posttoken&action=get-jsonatta" -o "$outfile" > /dev/null || exit 1

