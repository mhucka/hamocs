## ============================================================================
## Description : Makefile for generating formatted output for the handbook
## Author(s)   : Michael Hucka <mhucka@caltech.edu>
## Organization: California Institute of Technology
## Date created: 2014-01-24
## Source      : https://github.com/mhucka/hamocs
## ============================================================================
##
## Normal usage:
##
##   make
##       Regenerates the formatted HTML output in the directory $(output).
##
##   make clean
##       Deletes all HTML files from the directory $(output).
##
## ----------------------------------------------------------------------------

input  = contents
output = formatted

# The index file serves as a kind of marker file; it is always regenerated,
# and regenerating it causes everything else to be regenerated.  This is not
# the most efficient approach, but it makes this makefile simple, and
# besides, the handbook is short enough that the time to do it all is short.

handbook: $(output)/index.html

clean:
	rm -f $(wildcard $(output)/*.html)

# The following should be the list of main content files.  It EXCLUDES
# front-matter.txt, authors.txt, and contact.txt, mainly because they need to be
# formatted using different configuration settings later below.

body.txt-files  = \
	introduction.txt \
	types-of-standards.txt \
	arranging-funding.txt \
	organizing-a-community.txt \
	developing-specifications.txt \
	organizing-meetings.txt

# The remainder below should not need to change under most circumstances.

template-dir = src/handbook-templates

body-tp	     = $(template-dir)/body-template.html
author-tp    = $(template-dir)/author-template.html
single-pg-tp = $(template-dir)/single-page-template.html

header-tp    = $(template-dir)/header-template.html
nav-tp       = $(template-dir)/nav-template.html
toc-tp       = $(template-dir)/toc-template.html
index-top-tp = $(template-dir)/index-top-template.html
index-bot-tp = $(template-dir)/index-bottom-template.html

# There are dependencies between the Pandoc arguments listed here and the
# processing done below.  For instance, --toc and -number-sections must
# remain or the other stuff below will break.

args = \
	-f markdown \
	--data-dir $(output) \
	--include-in-header=$(header-tp) \
	--number-sections \
	--mathjax \
	--smart \
	--toc

# Pandoc doesn't offer a way to generate a table of contents for multipage
# HTML output.  The approach taken here uses two passes.  First, pandoc is
# run over each input file using a special template solely for generating the
# table of contents for one file.  The output is massaged using sed, and
# appended to a temporary file called toc.html.  Then, the content of this
# file is inserted into the navigation bar and the file index.html using sed
# for the former and simple file append commands for the latter.
#
# This convoluted mess should not be necessary for other output formats
# such as LaTeX and ePUB.  It's just the HTML case that needs this.

pandoc-toc  = pandoc $(args) --template=$(toc-tp)
pandoc-real = pandoc $(args) --include-before-body=nav.html

timestamp   = $(shell date '+%G-%m-%d %H:%M %Z')
file-count  = $(words $(body.txt-files))

sed-match   = .*\#\([^\"]*\).*<span class=\"toc-.*\">\(.*\)</span>\(.*\)</a>.*
sed-replace = <li><a href=\"$$out\#\1\"><span class=\"section-number\">\2</span>\3</a></li>

$(output)/index.html: $(header-tp) $(nav-tp) $(body-tp) $(author-templ) $(toc-tp)
$(output)/index.html: $(wildcard $(input)/*.txt)
$(output)/index.html: Makefile $(index-top-tp) $(index-bot-tp)
	mkdir -p $(output)
	make style-files
	rm -f toc.html
	num=1; \
	for in in $(body.txt-files); do \
	  out="$${in%.txt}.html"; \
	  offset=`expr $$num - 1`; \
	  $(pandoc-toc) --number-offset=$$offset -o $(output)/$$out $(input)/$$in; \
	  sed -n -e "s|$(sed-match)|$(sed-replace)|p" < $(output)/$$out >> toc.html; \
	  if test $$num -ne $(file-count); then \
	    echo "<li class=\"divider\">" >> toc.html; \
	  fi; \
	  num=`expr $$num + 1`; \
	done;
	sed -e '/<!-- @@HTML-TOC@@ -->/r toc.html' < $(nav-tp) > nav.html
	offset=0; \
	for in in $(body.txt-files); do \
	  out="$${in%.txt}.html"; \
	  $(pandoc-real) --template=$(body-tp) --number-offset=$$offset -o $(output)/$$out $(input)/$$in; \
	  offset=`expr $$offset + 1`; \
	done;
	$(pandoc-real) --template=$(author-tp) -o $(output)/authors.html $(input)/authors.txt
	$(pandoc-real) --template=$(single-pg-tp) -o $(output)/contact.html $(input)/contact.txt
	sed -e 's/<!-- @@TIMESTAMP@@ -->/$(timestamp)/' < $(input)/front-matter.txt > index.txt
	$(pandoc-real) --template=$(index-top-tp) -o $(output)/index.html index.txt
	cat toc.html >> $(output)/index.html
	$(pandoc-real) --template=$(index-bot-tp) -o index-bottom.html index.txt
	cat index-bottom.html >> $(output)/index.html
	rm -f toc.html nav.html index.txt index-bottom.html

# -----------------------------------------------------------------------------
# The following rules populate the formatted/css, etc., directories from the
# source files, and also describe some additional common dependencies.  It is
# unlikely that anything below this point needs to be changed in common
# updates of this Makefile.
# -----------------------------------------------------------------------------

handbook-css-files = \
	handbook.css

bootstrap-css-files = \
	bootstrap-theme.css \
	bootstrap-theme.min.css \
	bootstrap.css \
	bootstrap.min.css

bootstrap-img-files = \
	glyphicons-halflings-white.png \
	glyphicons-halflings.png

bootstrap-js-files = \
	bootstrap.min.js \
	html5shiv.js \
	jquery.min.js \
	less-1.3.3.min.js

bootstrap-font-files = \
	glyphicons-halflings-regular.eot \
	glyphicons-halflings-regular.svg \
	glyphicons-halflings-regular.ttf \
	glyphicons-halflings-regular.woff

$(output)/css/%.css: src/bootstrap/css/%.css
	$(shell [ -d $(output)/css ] || mkdir -p $(output)/css)
	cp -rp src/bootstrap/css/$(notdir $<) $(output)/css/$(notdir $<)

$(output)/css/%.css: src/handbook-css/%.css
	$(shell [ -d $(output)/css ] || mkdir -p $(output)/css)
	cp -rp src/handbook-css/$(notdir $<) $(output)/css/$(notdir $<)

$(output)/img/%.png: src/bootstrap/img/%.png
	$(shell [ -d $(output)/img ] || mkdir -p $(output)/img)
	cp -rp src/bootstrap/img/$(notdir $<) $(output)/img/$(notdir $<)

$(output)/js/%.js: src/bootstrap/js/%.js
	$(shell [ -d $(output)/js ] || mkdir -p $(output)/js)
	cp -rp src/bootstrap/js/$(notdir $<) $(output)/js/$(notdir $<)

$(output)/fonts/%.eot: src/bootstrap/fonts/%.eot
	$(shell [ -d $(output)/fonts ] || mkdir -p $(output)/fonts)
	cp -rp src/bootstrap/fonts/$(notdir $<) $(output)/fonts/$(notdir $<)

$(output)/fonts/%.svg: src/bootstrap/fonts/%.svg
	$(shell [ -d $(output)/fonts ] || mkdir -p $(output)/fonts)
	cp -rp src/bootstrap/fonts/$(notdir $<) $(output)/fonts/$(notdir $<)

$(output)/fonts/%.ttf: src/bootstrap/fonts/%.ttf
	$(shell [ -d $(output)/fonts ] || mkdir -p $(output)/fonts)
	cp -rp src/bootstrap/fonts/$(notdir $<) $(output)/fonts/$(notdir $<)

$(output)/fonts/%.woff: src/bootstrap/fonts/%.woff
	$(shell [ -d $(output)/fonts ] || mkdir -p $(output)/fonts)
	cp -rp src/bootstrap/fonts/$(notdir $<) $(output)/fonts/$(notdir $<)

css-files	= $(addprefix $(output)/css/,$(bootstrap-css-files)) \
		  $(addprefix $(output)/css/,$(handbook-css-files))
img-files	= $(addprefix $(output)/img/,$(bootstrap-img-files))
js-files	= $(addprefix $(output)/js/,$(bootstrap-js-files))
font-files	= $(addprefix $(output)/fonts/,$(bootstrap-font-files))
all-style-files = $(css-files) $(img-files) $(js-files) $(font-files)

style-files: $(all-style-files)

# -----------------------------------------------------------------------------
# Miscellaneous items.
# -----------------------------------------------------------------------------

.SUFFIXES:
.SUFFIXES: .txt .css .js .svg .ttf .eot .woff .png .jpg .html
