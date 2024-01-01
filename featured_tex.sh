#!/bin/bash

set -x

mkdir -p wikipedia
cd wikipedia

WIKILANG="en"
if [ $# -eq 1 ]; then
  FEATURED_TITLE="$1"
else
  # Define the Wikipedia API URL for fetching the featured article of the day
  DATE="$(date +'%Y/%m/%d')"
  WIKI_API_URL="https://api.wikimedia.org/feed/v1/wikipedia/$WIKILANG/featured/$DATE"
  
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
fi

# Retrieve the full wikitext source of the featured article
WIKITEXT_API_URL="https://$WIKILANG.wikipedia.org/w/api.php"
WIKITEXT_PARAMS="action=query&format=json&prop=revisions&rvprop=content&titles=$FEATURED_TITLE"

WIKITEXT_JSON=$(curl -s "$WIKITEXT_API_URL?$WIKITEXT_PARAMS")
WIKITEXT_SOURCE=$(echo "$WIKITEXT_JSON" | jq -r '.query.pages[].revisions[0]["*"]')

SAFE_TITLE=$(echo "$FEATURED_TITLE" | sed "s/[^0-9a-zA-Z]//g")

echo "Featured Wikipedia Article Title: $SAFE_TITLE"
echo "Full Wikitext Source of the Featured Article:"
echo "$WIKITEXT_SOURCE" > "$SAFE_TITLE.txt"

sed -i 's/{{lang|[^|]*|\([^}]*\)}}/\1/g' "$SAFE_TITLE.txt"
sed -i 's/{{transl|[^|]*|\([^}]*\)}}/\1/g' "$SAFE_TITLE.txt" 
sed -i 's/{{gloss|\([^}]*\)}}/\1/g' "$SAFE_TITLE.txt"

pandoc --from mediawiki --to latex -s -V papersize=a5 -V geometry:margin=1cm -V mainfont="Liberation Serif" -V lang=$WIKILANG "$SAFE_TITLE.txt" -o "$SAFE_TITLE.tex"
lualatex --interaction=nonstopmode "$SAFE_TITLE.tex"
inkscape "$SAFE_TITLE.pdf" --pdf-poppler --export-page=1 --export-type="dxf" --export-extension=org.ekips.output.dxf_outlines
