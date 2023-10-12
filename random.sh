#!/bin/bash

while true; do
# Define the Wikipedia API URL for fetching a random page
WIKI_API_URL="https://en.wikipedia.org/w/api.php"

# Define parameters for the API request
PARAMS="action=query&format=json&list=random&rnnamespace=0&rnlimit=1"

# Make the API request to get a random page title
RANDOM_PAGE_TITLE=$(curl -s "$WIKI_API_URL?$PARAMS" | jq -r '.query.random[0].title|@uri')

if [ -z "$RANDOM_PAGE_TITLE" ]; then
  echo "Failed to fetch a random Wikipedia page title."
  exit 1
fi

# Fetch the content of the random page
CONTENT_API_URL="https://en.wikipedia.org/w/api.php"
PARAMS="action=query&format=json&prop=extracts&exintro=true&explaintext=true&titles=$RANDOM_PAGE_TITLE"

RANDOM_PAGE_TEXT=$(curl -s "$CONTENT_API_URL?$PARAMS" | jq -r '.query.pages[].extract')

echo "Random Wikipedia Page Text:"
echo "$RANDOM_PAGE_TEXT" | tee random.txt

[ ${#RANDOM_PAGE_TEXT} -gt 10 ] && break
done


vpype --config vpype.toml pagesize a5 text --position 1cm 1cm --wrap 10cm --font cursive --size 32pt --justify "$RANDOM_PAGE_TEXT" linemerge show gwrite --profile pybricks random.py
