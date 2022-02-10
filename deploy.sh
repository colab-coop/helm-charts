#!/bin/sh

set -ex

chart_dir=$1
dir=$(git rev-parse --show-toplevel)/$chart_dir

if ([ -z "$chart_dir" ]); then
  echo "Please specify whihch chart to deploy"
  exit 1
fi

chart=$(find . -name "$dir-*.tgz" | sed "s|^\./||")
git_tag=${chart%.tgz}

if ! (output=$(git status --porcelain) && [ -z "$output" ]); then
  git add .
  git commit -m "Release $git_tag changes"
  git push origin main
fi

repo=$(git rev-parse --show-toplevel)/docs/charts/

helm package $dir
mv $chart $repo
helm repo index $repo --url https://colab-coop.github.io/helm-charts/charts/

git add -A $repo
git commit -m "Release $git_tag package"
git tag $git_tag
git push origin main --tags
