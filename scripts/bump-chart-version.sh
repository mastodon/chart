#!/usr/bin/env bash
# thanks to original comment: https://github.com/renovatebot/renovate/issues/8231#issuecomment-1978929997
# converted to discussion: https://github.com/renovatebot/renovate/discussions/28861#discussioncomment-9326722

set -euo pipefail

update_type="$1"

version=$(grep "^version:" "charts/mastodon/Chart.yaml" | awk '{print $2}')

if [[ ! $version ]]; then
  echo "No valid version was found"
  exit 1
fi

major=$(echo "$version" | cut -d. -f1)
minor=$(echo "$version" | cut -d. -f2)
patch=$(echo "$version" | cut -d. -f3)

if [[ "$update_type" =~ (major|replacement) ]]; then
  major=$(( major + 1 ))
  minor=0
  patch=0
elif [[ "$update_type" =~ 'minor' ]]; then
  minor=$(( minor + 1 ))
  patch=0
else
  patch=$(( patch + 1 ))
fi

echo "Bumping version for mastodon chart from $version to $major.$minor.$patch"
sed -i "s/^version:.*/version: ${major}.${minor}.${patch}/g" "charts/mastodon/Chart.yaml"
