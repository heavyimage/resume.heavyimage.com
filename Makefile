OUT_DIR=output
IN_DIR=markdown
STYLES_DIR=styles
STYLE=chmduquesne
MDFILE=metadata.yaml

# The pandoc / mtxrun workflow doesn't properly support the --metadata-file flag
# Workaround by populating the template at compile time with values read from
# the ${MDFILE} file!
TITLE = $(shell grep "^title" ${MDFILE} | cut -d":" -f2 | sed 's/\"//g' | xargs)
SUBTITLE = $(shell grep "^subtitle" ${MDFILE} | cut -d":" -f2 | sed 's/\"//g' | xargs)
AUTHOR = $(shell grep "^author" ${MDFILE} | cut -d":" -f2 | sed 's/\"//g' | xargs)
KEYWORDS = $(shell grep "^keywords" ${MDFILE} | cut -d":" -f2 | sed 's/\"//g' | sed 's/[][]//g' | xargs)

all: html pdf docx rtf

pdf: init
	for f in $(IN_DIR)/*.md; do \
		FILE_NAME=`basename $$f | sed 's/.md//g'`; \
		echo "Creating $$FILE_NAME.pdf"; \
		sed 's/SUBTITLE/${SUBTITLE}/; s/AUTHOR/${AUTHOR}/g; s/TITLE/${TITLE}/; s/KEYWORDS/${KEYWORDS}/' $(STYLES_DIR)/$(STYLE).tex > /tmp/style.tex; \
		pandoc --standalone --template /tmp/style.tex \
			--from markdown --to context \
			--variable papersize=A4 \
			--output $(OUT_DIR)/$$FILE_NAME.tex $$f > /dev/null;\
		mtxrun --path=$(OUT_DIR) --result=$$FILE_NAME.pdf --script context $$FILE_NAME.tex > $(OUT_DIR)/context_$$FILE_NAME.log 2>&1; \
	done

html: init
	for f in $(IN_DIR)/*.md; do \
		FILE_NAME=`basename $$f | sed 's/.md//g'`; \
		echo "Creating $$FILE_NAME.html"; \
		pandoc --standalone --include-in-header $(STYLES_DIR)/$(STYLE).css \
			--lua-filter=pdc-links-target-blank.lua \
			--from markdown --to html \
			--metadata-file=${MDFILE} \
			--output $(OUT_DIR)/$$FILE_NAME.html $$f; \
	done

docx: init
	for f in $(IN_DIR)/*.md; do \
		FILE_NAME=`basename $$f | sed 's/.md//g'`; \
		echo "Creating $$FILE_NAME.docx"; \
		pandoc --standalone $$SMART $$f \
			    --metadata-file=${MDFILE} \
			   --output $(OUT_DIR)/$$FILE_NAME.docx; \
	done

rtf: init
	for f in $(IN_DIR)/*.md; do \
		FILE_NAME=`basename $$f | sed 's/.md//g'`; \
		echo "Creating $$FILE_NAME.rtf"; \
		pandoc --standalone $$SMART $$f \
			   --metadata-file=${MDFILE} \
			   --output $(OUT_DIR)/$$FILE_NAME.rtf; \
	done

init: dir version

dir:
	mkdir -p $(OUT_DIR)

version:
	PANDOC_VERSION=`pandoc --version | head -1 | cut -d' ' -f2 | cut -d'.' -f1`; \
	if [ "$$PANDOC_VERSION" -eq "2" ]; then \
		SMART=-smart; \
	else \
		SMART=--smart; \
	fi \

clean:
	rm -f $(OUT_DIR)/*
