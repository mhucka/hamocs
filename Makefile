input  = contents
output = formatted

handbook: $(output)/index.html

body-md-files  = \
	introduction.md \
	managing-expectations.md \
	arranging-funding.md \
	organizing-meetings.md

template-dir = src/handbook-templates

body-tp	     = $(template-dir)/body-template.html
author-tp    = $(template-dir)/author-template.html
single-pg-tp = $(template-dir)/single-page-template.html

header-tp    = $(template-dir)/header-template.html
nav-tp       = $(template-dir)/nav-template.html
toc-tp       = $(template-dir)/toc-template.html
index-top-tp = $(template-dir)/index-top-template.html
index-bot-tp = $(template-dir)/index-bottom-template.html

args = \
	-f markdown \
	--include-in-header=$(header-tp) \
	--number-sections \
	--data-dir formatted \
	--mathjax \
	--smart \
	--toc

pandoc-toc  = pandoc $(args) --template=$(toc-tp)
pandoc-real = pandoc $(args) --include-before-body=nav.html

timestamp   = $(shell date '+%G-%m-%d %H:%M %Z')
file-count  = $(words $(body-md-files))

sed-match   = .*\#\([^\"]*\).*\(<span class=\"header-section.*\)</a>.*
sed-replace = <li><a href=\"$$out\#\1\">\2</a></li>

$(output)/index.html: $(header-tp) $(nav-tp) $(body-tp) $(author-templ) $(toc-tp)
$(output)/index.html: $(wildcard $(input)/*.md)
$(output)/index.html: Makefile $(index-top-tp) $(index-bot-tp)
	make style-files
	rm -f toc.html
	num=1; \
	for in in $(body-md-files); do \
	  out="$${in%.md}.html"; \
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
	for in in $(body-md-files); do \
	  out="$${in%.md}.html"; \
	  $(pandoc-real) --template=$(body-tp) --number-offset=$$offset -o $(output)/$$out $(input)/$$in; \
	  offset=`expr $$offset + 1`; \
	done;
	$(pandoc-real) --template=$(author-tp) -o $(output)/authors.html $(input)/authors.md
	$(pandoc-real) --template=$(single-pg-tp) -o $(output)/contact.html $(input)/contact.md
	sed -e 's/<!-- @@TIMESTAMP@@ -->/$(timestamp)/' < $(input)/front-matter.md > index.md
	$(pandoc-real) --template=$(index-top-tp) -o $(output)/index.html index.md
	cat toc.html >> $(output)/index.html
	$(pandoc-real) --template=$(index-bot-tp) -o index-bottom.html index.md
	cat index-bottom.html >> $(output)/index.html
	rm -f toc.html nav.html index.md index-bottom.html

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
.SUFFIXES: .md .css .js .svg .ttf .eot .woff .png .jpg .html
