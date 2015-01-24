DIR_MAKER=@mkdir -p $(@D) 
LUA=luajit
export LUA_PATH=src/lua/?.lua
SYNC=rsync -a --exclude=".gitignore" --out-format="copying %f%L"
.DELETE_ON_ERROR: #delete target if fails
.PHONY: all content scss js assets src clean fresh reload refresh newpost
all:content assets src

CACHE_TARGET =$(patsubst rsrc/%/meta.lua,.lua_cache/%.lua,$(wildcard rsrc/*/*/meta.lua))
SCSS_SOURCES =$(wildcard rsrc/assets/scss/*.scss)
JS_SOURCES   =$(wildcard rsrc/assets/js/*.js)

content:site/lua/content.lua
site/lua/content.lua: $(CACHE_TARGET)
	$(DIR_MAKER)
	@printf "making index..."
	@printf '%s\n' $(CACHE_TARGET) | $(LUA) src/lua/mkindex.lua > $@
	@printf "done\n"
.lua_cache/%.lua:rsrc/%/meta.lua rsrc/%/index.md
	$(DIR_MAKER)
	$(LUA) src/lua/mkpost.lua rsrc/$* > $@

assets:scss js
	@mkdir -p site/assets
	@GLOBIGNORE="*scss:*js"; $(SYNC) rsrc/assets/* site/assets/

ifeq ($(strip $(SCSS_SOURCES)),)
scss:
else
scss:site/assets/index.css
site/assets/index.css .INTERMEDIATE:rsrc/assets/index.scss
	$(DIR_MAKER)
	sassc -t compressed $< > $@
rsrc/assets/index.scss:$(SCSS_SOURCES)
	cat $^ > $@ </dev/null
endif

ifeq ($(strip $(JS_SOURCES)),)
js:
else
js:site/assets/index.js
site/assets/index.js:$(JS_SOURCES)
	$(DIR_MAKER)
	uglifyjs $^ -o $@ -c -m </dev/null
endif

src:
	@mkdir -p site/logs
	@if [ -f .nginx.pid ]; then mv .nginx.pid site/logs/nginx.pid; fi
	@$(SYNC) src/site/* site/
	@$(SYNC) rsrc/templates site/lua

clean:
	@if [ -e site/logs/nginx.pid ]; then mv site/logs/nginx.pid .nginx.pid; fi
	rm -rf .lua_cache/ site/
fresh: clean all
reload: all
	nginx -p site -c conf/nginx.conf `if [ -f site/logs/nginx.pid ]; then echo "-s reload"; fi`
refresh: reload
	src/sh/reload.sh "localhost:8080/"
newpost:
	src/sh/newpost.sh
