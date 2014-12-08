DIR_MAKER=@mkdir -p $(@D) 
.DELETE_ON_ERROR: #delete target if fails
.PHONY: all posts pages imgs scss js assets clean 
all:posts pages assets

POSTS_SOURCES=$(wildcard rsrc/posts/*/*.md)
PAGES_SOURCES=$(wildcard rsrc/pages/*.md) 
SCSS_SOURCES =$(wildcard rsrc/assets/scss/*.scss)
IMG_SOURCES  =$(wildcard rsrc/assets/imgs/*)
JS_SOURCES   =$(wildcard rsrc/assets/js/*.js)
POSTS_TARGET =$(patsubst rsrc/posts/%.md,site/%.html,$(POSTS_SOURCES)) 
PAGES_TARGET =$(patsubst rsrc/pages/%.md,site/%.html,$(PAGES_SOURCES))

posts:$(POSTS_TARGET)
site/%.html:rsrc/posts/%.md
	$(DIR_MAKER)
	pandoc -f markdown -t html5 -o $@ $<

pages:$(PAGES_TARGET)
site/%.html:rsrc/pages/%.md
	$(DIR_MAKER)
	pandoc -f markdown -t html5 -o $@ $<

imgs:$(IMG_SOURCES)
	@mkdir -p site
	cp -R rsrc/assets/imgs/. site/

scss:site/index.css
site/index.css:rsrc/assets/index.scss
	@mkdir -p site
	sassc -t compressed $< > $@
	rm $<
rsrc/assets/index.scss:$(SCSS_SOURCES)
	cat $^ > $@ </dev/null

js:site/index.js
site/index.js:$(JS_SOURCES)
	uglifyjs $^ -o $@ -c -m </dev/null

assets:imgs scss js

clean:
	rm -rf site/
