#!/bin/env bash

PRIVATE_DIR="$HOME/.private/pinterest-feed-scraper"
mkdir -p $PRIVATE_DIR
touch $PRIVATE_DIR/cookies.txt
SESSION=`grep -oh "_pinterest_sess\s[^$]*" $PRIVATE_DIR/cookies.txt | awk -v N=2 '{print $N}'`

if [[ -z "$SESSION" ]]; then
  echo "Error: Pinterest session cookie not found. Please add it to $PRIVATE_DIR/cookies.txt"
  exit 1
fi

TARGET_DIR=$1
mkdir -p $TARGET_DIR

if [[ -z "$TARGET_DIR" ]]; then
  echo "Usage: $0 <target_directory>"
  exit 1
fi

for cmd in curl jq; do
  if ! command -v $cmd &> /dev/null; then
    echo "Error: $cmd is not installed. Please install it and try again."
    exit 1
  fi
done

scrape_feed() {
  response=$( \
      curl 'https://it.pinterest.com/resource/UserHomefeedResource/get/?source_url=%2F&data=%7B%22options%22%3A%7B%22field_set_key%22%3A%22hf_grid%22%2C%22in_nux%22%3Afalse%2C%22in_news_hub%22%3Afalse%2C%22static_feed%22%3Afalse%2C%22bookmarks%22%3A%5B%22Y2JVSG80T1ZFd1JrSlJhMFpDVVZWR1FsRlhPVUpSVjJSQ1VWVkdZV0V3U1hwVWJFa3lVVEJHUWxKRlJrSlJWVVp6VlZjNVFsRnJaM1pNZVRoMlRIazRka3d6UlRKUk1FWkNVakJHUWxGVlJuTmFNamxDVVRCbmRreDVPSFpNZVRoMlRETkZNbEZWUlRsUVdIZDRUbFJKZWs1NlZURk5SR00wVFZSSk1rMUVVWGxMYTJSU1ZFTndPRnBxUlRKTmVtTjVUMGRWTWxwVVFURmFWR042VG5wamQxbDZRVEJOZWtrMFRVUnNiRTE2U1RKWlYxSnNUbTFSTVUxcVJYbFphbWQzVGpKS2ExcFhUWGhOVjBwb1QxUm5lRTFIVVhwWmFteHNUMGRhYVZwWWVFOVNWbVE0fFVIbzVSbUpwYzNKTlIxSk5UMFYwVkU5RU1XWk5WRlYzV0hrd2VHWkVSVEZOYWswelRsUlZkMDU2WjNoTmFsbDNUa1JKY1ZJeFJrMUxibmN6VFRKWmVWbHFWbWxOVjFVMVdsUkJNRTF0U1RKWmJVa3dUMVJOTUZwWFVUTlBWMFY2VFhwak5WbFhTbTFhUkZacFQxZEplbHBIVVRCYVIwWm9UakpOTTFsdFZYcFpWR040V1hwU2FFMUVUbXBOZWtKcFprVTFSbFl6ZHowPXxVSG80ZUUxNmFEaE5WRlY1VFhwak1VNVVRVE5QUkVWNVRtcEJNRTFwY0VoVlZYZHhaa2RaTVU1cWJHdGFWR3Q0VFVScmVGbFhSWGhhUjAweldXcFpkMDVFVlhsTlJGa3lUbXBGTUU1WFNtaFBWMFpzVG1wSmVscEVhekZaVkZKdFdXcHNhRTU2U1hsYVJFRTBXbXBPYWs1VVl6VmFWRVY0VDFSR09GUnJWbGhtUVQwOXwxNTIzNzU1MDc4MTI2MDQyKkdRTCp8MGQ3YjQ2YWJhNGU1ZGRlZjYyMmYzZTk1MWM0NGJhMjQzZjQwYTQ3ZjIxMDZmMzgxZTU0OGU4OGExYmY4ZThlNnxORVd8%22%5D%7D%2C%22context%22%3A%7B%7D%7D&_=1756672949298' \
      --compressed \
      -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:142.0) Gecko/20100101 Firefox/142.0' \
      -H 'Accept: application/json, text/javascript, */*, q=0.01' \
      -H 'Accept-Language: it-IT,it;q=0.8,en-US;q=0.5,en;q=0.3' \
      -H 'Accept-Encoding: gzip, deflate, br, zstd' \
      -H 'Referer: https://it.pinterest.com/' \
      -H 'X-Requested-With: XMLHttpRequest' \
      -H 'X-APP-VERSION: 9d30d92' \
      -H 'X-Pinterest-AppState: background' \
      -H 'X-Pinterest-Source-Url: /' \
      -H 'X-Pinterest-PWS-Handler: www/index.js' \
      -H 'screen-dpr: 1' \
      -H 'X-B3-TraceId: 3b1e55c687701466' \
      -H 'X-B3-SpanId: 2d6093676a7de43a' \
      -H 'X-B3-ParentSpanId: 3b1e55c687701466' \
      -H 'X-B3-Flags: 0' \
      -H 'DNT: 1' \
      -H 'Sec-GPC: 1' \
      -H 'Sec-Fetch-Dest: empty' \
      -H 'Sec-Fetch-Mode: cors' \
      -H 'Sec-Fetch-Site: same-origin' \
      -H 'Connection: keep-alive' \
      -H 'Alt-Used: it.pinterest.com' \
      -H "Cookie: _pinterest_sess=$SESSION" \
    )

  if [[ $? -ne 0 ]]; then
    error_msg="Failed to fetch Pinterest feed. Please connection or try re-authenticating \
      from your browser and updating the session cookie in $PRIVATE_DIR/cookies.txt"
    notify-send "Pinterest Feed Scraper" "$error_msg"
    echo $error_msg
    exit 1
  fi

  echo $response

  images=$(echo $response | jq -cr ".resource_response.data[] | {url: .images.orig.url, user: .pinner.username}")

  for image in $images; do
    url=`echo $image | jq -r ".url"`
    user=`echo $image | jq -r ".user"`
    curl --skip-existing -s "$url" -o "$TARGET_DIR/PINSCRAPED_${user}_$(basename $url)"
  done
}

cleanup_old_images() {
  #remove images older than 7 days
  # find "$TARGET_DIR" -type f -name "[PINSCRAPED]_*.jpg" -mtime +7 -exec rm {} \;
  # remove all picture except the latest 200
  ls -t "$TARGET_DIR"/PINSCRAPED_*.jpg | sed -e "1,200d" | xargs -d '\n' rm -f
}

scrape_feed
cleanup_old_images
