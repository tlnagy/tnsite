---
title: "Embedding videos in Google Slides as GIFs"
author: Tamas Nagy
layout: post
tags: [science, productivity]
---

In my field, systems biology, it's pretty common to take time-lapse movies
to get the dynamics of how the system behaves. And we like showing them
off. This makes Google Slides[^1] inability to embed videos (without
uploading them to Youtube) pretty annoying and inconvenient. Slides does,
on the other hand, have good support for embedding GIFs. I came up with
the following pipeline (based on notedible's comment on
[Stackoverflow](https://superuser.com/questions/556029/how-do-i-convert-a-video-to-gif-using-ffmpeg-with-reasonable-quality)).
First, make sure to install `libav` and `imagemagick`. On Debian-based
systems, you can run 

```
sudo apt-get install libav-tools imagemagick
```

and on MacOS[^2] the easiest way to install them is via
[homebrew](http://brew.sh). Then I use the following command to create the GIF:

```
cat some_movie.m4v | avconv -i pipe: -r 10 -f image2pipe -vcodec ppm - | convert -delay 5 -loop 0 - gif:- | convert -layers Optimize - output.gif
```

where `some_movie.m4v` is the video file. This creates an optimized GIF
version called `output.gif`, which you can then upload to Google Slides.
The last niggle is that the GIFs play continuously and sometimes it's
helpful to be able to stop/start the playback. Enter the [Toggle Animated
Gifs](https://addons.mozilla.org/en-US/firefox/addon/toggle-animated-gifs/)
extension for Firefox (I'm sure there's something comparable for Chrome),
which lets you do just that.


[^1]: I like Google Slides for a variety of reasons, but the main ones are
its simplicity, portability, and collaboration features. Hard to beat for
presentations.

[^2]: OS X dammit
