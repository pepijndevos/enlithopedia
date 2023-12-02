#!/bin/bash

# Define the Wikipedia API URL for fetching the featured article of the day
WIKI_API_URL="https://api.wikimedia.org/feed/v1/wikipedia/en/featured/$(date +'%Y/%m/%d')"

# Make the API request to get the featured article of the day in JSON format
FEATURED_ARTICLE_JSON=$(curl -s "$WIKI_API_URL")

if [ -z "$FEATURED_ARTICLE_JSON" ]; then
  echo "Failed to fetch the featured article of the day."
  exit 1
fi

# Extract the title and content of the featured article from the JSON response using jq
FEATURED_TITLE=$(echo "$FEATURED_ARTICLE_JSON" | jq -r '.tfa.title')
FEATURED_EXTRACT=$(echo "$FEATURED_ARTICLE_JSON" | jq -r '.tfa.extract')

echo "Featured Wikipedia Article Title: $FEATURED_TITLE"
echo "Featured Wikipedia Article Extract:"
echo "$FEATURED_EXTRACT"

# Retrieve the full text of the featured article
FULL_TEXT_API_URL="https://en.wikipedia.org/w/api.php"
FULL_TEXT_PARAMS="action=query&format=json&prop=extracts&exsentences=4&explaintext=true&titles=$FEATURED_TITLE"

FULL_TEXT=$(curl -s "$FULL_TEXT_API_URL?$FULL_TEXT_PARAMS" | jq -r '.query.pages[].extract')

echo "Full Text of the Featured Article:"
echo "$FULL_TEXT"

#vpype --config vpype.toml pagesize a5 text --position 1cm 1cm --wrap 12.5cm --size 22pt --hyphenate en --justify "$FULL_TEXT" linemerge show gwrite --profile pybricks random.py
vpype --config vpype.toml pagesize a5 text --position 1cm 1cm --wrap 12.5cm --size 22pt --hyphenate en --justify "$FULL_TEXT" linemerge show gwrite --profile cnc featured.gcode

