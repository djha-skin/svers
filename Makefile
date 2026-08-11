.PHONY: all docs

BUILD_DIR=docs/build/svers-version-comparison-library/
SIMPLE_DIR=$(BUILD_DIR)/simple
HTML_DIR=$(BUILD_DIR)/html
HTML_FILES=$(HTML_DIR)/overview.html $(HTML_DIR)/api-reference.html
SIMPLE_HTML_FILES=$(SIMPLE_DIR)/overview.html $(SIMPLE_DIR)/api-reference.html

docs: $(HTML_DIR)/manual.pdf $(HTML_FILES)

$(HTML_DIR)/manual.pdf: $(SIMPLE_HTML_FILES)
	pandoc  -t pdf \
			-f html \
			-o $(HTML_DIR)/manual.pdf \
			--toc \
			--metadata "author=Daniel Jay Haskin" \
			--metadata "title=svers: Version Comparison Library" \
			--file-scope \
			--indented-code-classes=lisp \
			-V colorlinks=true \
			-V 'fontsize=12pt' \
			-V 'geometry=margin=1in' \
			$(SIMPLE_HTML_FILES)

$(HTML_FILES): docs/manual.scr docs/manifest.lisp
	./docs/build-docs.ros
	mkdir -p docs/build/svers-version-comparison-library/html/assets/
	rsync -avHAX docs/assets/ docs/build/svers-version-comparison-library/html/assets/
	cd docs/build/svers-version-comparison-library/html/ && \
		mv assets/favicon.ico . && \
		rm -f index.html && \
		ln -s overview.html index.html

$(SIMPLE_DIR)/%.html: $(HTML_DIR)/%.html
	mkdir -p $(SIMPLE_DIR)
	xmlstarlet format --omit-decl --recover --html $< | \
		xmlstarlet edit \
		    --pf --omit-decl \
			--rename "//h3" -v "h4" \
			--rename "//h2" -v "h3" \
			--rename "//h1" -v "h2" \
			--rename "//h2[@class='doc-title']" -v "h1" \
			--delete "//aside" \
			--delete '//footer' | \
			sed -e 's|svers: Version Comparison Library &#xBB; ||g' \
			> $@