---
title: Building this Jekyll site on Debian 8
author: Tamas Nagy
layout: post
---

One of my goals with the redesign was to improve the portability of my
site's stack. It's now pretty simple getting it to work on a fresh Linux
install. For example, on [Debian Jessie](https://debian.org), install the
following packages:

``` 
sudo apt-get install ruby ruby-dev git imagemagick libmagickwand-dev pandoc pandoc-citeproc
```

If using an older version of jekyll (<3) then also install a valid
Javascript runtime like NodeJS[^1]:

```
sudo apt-get install nodejs
```

then install all the required Ruby gems:

```
sudo gem install jekyll -v 2.5.1
sudo gem install exifr rmagick jekyll-pandoc
```

Finally clone the git repo and build the site:

```
git clone https://github.com/tlnagy/tnsite.git
cd tnsite
jekyll serve
```

Voilà

[^1]: This is still required to build this site until I fix
<https://github.com/tlnagy/tnsite/issues/3>
