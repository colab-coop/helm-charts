#!/bin/sh

set -ex

chart_dir=$1
dir=$(git rev-parse --show-toplevel)/$chart_dir

if ([ -z "$chart_dir" ]); then
  echo "Please specify whihch chart to deploy"
  exit 1
fi

if ! (output=$(git status --porcelain) && [ -z "$output" ]); then
  git add .
  git commit -m "Release candidate"
  git push origin main
fi

helm package $chart_dir

chart=$(find .  -maxdepth 1 -name "$chart_dir-*.tgz" | sed "s|^\./||")
repo=$(git rev-parse --show-toplevel)/docs/charts/
tag=${chart%.tgz}

if test -f "$repo$chart"; then
  rm -rf $repo$chart
fi

mv $chart $repo
helm repo index $repo --url https://colab-coop.github.io/helm-charts/charts/

git add -A $repo
git commit -m "Release $tag package"
git tag $tag
git push origin main --tags
