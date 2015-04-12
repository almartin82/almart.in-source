# almart.in-source
source &amp; config for almart.in pelican static site.  

## does this even need to be in version control?
at first, I thought not, but after perusing some of the pelican [themes](https://github.com/getpelican/pelican-themes) I found that it was helpful to see people's full setup (especially the `pelicanconf.py` file), and given that everything's going on the internet _anyways_, figured I'd err on the comprehensive side.

## organization
this is the top level directory for almart.in content.  there are two other repos:

1. [`almart.in`](https://github.com/almartin82/almart.in), which is the pelican output directory (look at [`pelicanconf.py`](https://github.com/almartin82/almart.in-source/blob/master/pelicanconf.py) for more detail). pushing to the `gh-pages` branch of this repo hosts the content for [almart.in](http://almart.in/)

2. ['safetoeat'](https://github.com/almartin82/safetoeat), the custom pelican theme for almart.in.  keeping this in a separate repo to make it easy to eventually contribute back to the larger [repo](https://github.com/getpelican/pelican-themes) of pelican themes.

both of these live as subdirectories on my local machine.  they're .gitignored here to avoid unnecessary duplication.  

## deploying (in case you forget)

1. write some new .md in `content/`, then `pelican content` to build the site.

2. `cd almart.in`; `git add .`, `git push origin gh-pages`
 