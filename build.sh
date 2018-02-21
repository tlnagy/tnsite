#!/bin/bash 

# stash all uncommitted changes
echo -n "Saving working directory state..."
git stash -q
og_dir=$(pwd)
echo "Done."

# cleans up working directory on exit
function cleanup {
  echo -n "Restoring original directory state..."
  cd "$og_dir"
  git stash pop -q
  echo "Done."
}
trap cleanup EXIT

# build site
bundle exec jekyll build

# rebuilds pdf if needed
if [ cv.md -nt "$0" ] || [ ! -f _site/assets/tamasnagy_cv.pdf ]; then
  echo "CV changed or missing, generating PDF"
  pandoc cv.md --template=cv_template.tex -o assets/tamasnagy_cv.pdf
  cp assets/tamasnagy_cv.pdf _site/assets/tamasnagy_cv.pdf
fi
touch "$0"

# deploy
if [ "$1" != "--deploy" ]; then
  exit 0
fi

cd _site/
git add *
git commit -m "generate site"
git push origin master
