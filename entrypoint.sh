#! /bin/sh

# Get the GitHub token and Giphy API Key from Github Actions Input parameters
GITHUB_TOKEN=$1
GIPHY_API_KEY=$2

# Get the pull request number from the GitHub Event Payload
pull_request_number=$(jq --raw-output .pull_request.number "$GITHUB_EVENT_PATH")
echo PR Number = $pull_request_number

# Use the Giphy API to fetch a random Thank You GIF
giphy_response=$(curl -s "https://api.giphy.com/v1/gifs/random?api_key=$GIPHY_API_KEY&tag=thank+you&rating=g")
echo Giphy Resposne = $giphy_response

# Extract the GIF URL from Giphy response
gif_url=$(echo "$giphy_response | jq --raw-output .data.images.downsized.url")
echo GIPHY_URL - $gif_url

# Create a comment with the GIF on the pull request
comment_response=$(curl -s \
  -X POST \
  -H "Accept: application/vnd.github+json" \
  -H "Authorization: Bearer $GITHUB_TOKEN" \
  -H "X-GitHub-Api-Version: 2022-11-28" \
  https://api.github.com/repos/$GITHUB_REPOSITORY/issues/$pull_request_number/comments \
  -d "{\"body\": \"### PR - #$pull_request_number. \n ### :octocat: ⚡ Thank You for this contribution! \n ![GIF]($gif_url)\"}")

# Extract and print eh comment URL from the comment response
comment_url=$(echo "$comment_response" | jq --raw-output .html_url)
