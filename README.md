# [deltaepsilon.ca](https://deltaepsilon.ca/)

A personal blog created using the [Hugo](https://gohugo.io/) static site generator. The theme is a
[slightly tweaked version of Kiera](https://github.com/lauhayden/hugo-kiera).

## No analytics, no CDN

The policy for this site is that I won't use anything other than my own infrastructure to host. Everything needed for the site is on Github in this repo and the theme repo. All CDN-served files have been vendored so that clients visiting the site only make connections to machines I admin.

## Writing a post

`hugo new posts/<new-post-filename>.md`

`make serve`

`make`

`make deploy`
