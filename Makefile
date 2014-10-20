DIR_MAKER=@mkdir -p $(@D) # -p means that if dir exists, do nothing,
                          # and create other dirs as needed
													# @D is the var of the dir of the target
													# (this is like doing a #DEFINE)
.PHONY: posts clean 
POSTS_SOURCES=$(wildcard rsrc/posts/*/*.md) # find a list of all files matching the 
                                            # pattern and assign to the var POSTS_SOURCES
POSTS_HTML   =$(patsubst rsrc/posts/%.md,site/%.html,$(POSTS_SOURCES)) # takes POSTS_SOURCES
                                            # and replace all instances of
																						# first arg with second arg pattern
posts:$(POSTS_HTML) # when you make posts, it needs all the files in POSTS_HTML to exist
	                 @# if they don't exist, it sees if it can make them
site/%.html:rsrc/posts/%.md # this is a new target, which requires the .md files
	                         @# implicitly make site/%.html for all html needed
	$(DIR_MAKER)
	@pandoc -f markdown -t html5 -o $@ $< # this is what it does to make html files

clean:
	rm -rf site/
