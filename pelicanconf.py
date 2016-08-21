#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

#page parameters
AUTHOR = u'Andrew Martin'
SITENAME = u'almart.in'
SITEURL = u'http://almart.in'
DESCRIPTION = u'r, #rstats, ggplot2, python, pandas, education, data science, statistical programming, maps, baseball, brooklyn'

#pelican parameters
OUTPUT_PATH = '../almart.in/'
PATH = 'content'
TIMEZONE = 'America/New_York'
DEFAULT_DATE_FORMAT = '%B %d %Y'
DEFAULT_LANG = u'en'
DEFAULT_PAGINATION = False
THEME = '../more_wilson/'
GOOGLE_ANALYTICS = True
GOOGLE_ANALYTICS_ID = 'UA-61809650-1'
OUTPUT_SOURCES = 'True'
OUTPUT_SOURCES_EXTENSION = '.txt'
SUMMARY_MAX_LENGTH = 250

# feed generation
# FEED_ALL_ATOM = '/feeds/all_atom.xml'
# CATEGORY_FEED_ATOM = 'feeds/%s.atom.xml'

#more_wilson settings
USE_COMMENTS = False

MENUITEMS = [
    ('about', 'user', 'pages/about.html'),
]

# look at base_site.html for these
MEDIAITEMS = [
    ('https://twitter.com/moneywithwings', 'twitter', ' moneywithwings'),
    ('mailto:almartin at gmail dot com', 'envelope', 'almartin at gmail dot com'),
    ('http://github.com/almartin82', 'github', ' almartin82'),
    ('https://www.goodreads.com/user/show/777050-andrew-martin', 'book', 'Andrew Martin'),
    ('https://keybase.io/almartin', 'key', ' almartin'),
    ('http://www.linkedin.com/in/martinandrewl', 'linkedin', ' Andrew Martin'),
]

#plugins etc
PLUGIN_PATHS = ['../pelican-plugins/']
PLUGINS = ['post_stats', 'summary', 'rmd_reader']

#knitr/rmd integration
STATIC_PATHS = ['static_images', 'datasets', 'figure']

# Uncomment following line if you want document-relative URLs when developing
#RELATIVE_URLS = True
