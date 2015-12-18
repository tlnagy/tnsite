#!/bin/bash 

jekyll build

if [ cv.md -nt "$0" ] || [ ! -f _site/assets/tamasnagy_cv.pdf ]; then
  echo "CV changed or missing, generating PDF"
  pandoc cv.md -o _site/assets/tamasnagy_cv.pdf
fi
touch "$0"
