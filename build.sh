#!/bin/bash 

jekyll build

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
cd ..
