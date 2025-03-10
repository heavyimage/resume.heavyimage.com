OUT_DIR=output
IN_DIR=markdown
STYLES_DIR=styles
STYLE=chmduquesne
CUSTOM_HTML_TEMPLATE=custom.html
MDFILE=metadata.yaml

# The pandoc / mtxrun workflow doesn't properly support the --metadata-file flag
# Workaround by populating the template at compile time with values read from
# the ${MDFILE} file!
TITLE = $(shell grep "^title" ${MDFILE} | cut -d":" -f2 | sed 's/\"//g' | xargs)
SUBTITLE = $(shell grep "^subtitle" ${MDFILE} | cut -d":" -f2 | sed 's/\"//g' | xargs)
AUTHOR = $(shell grep "^author" ${MDFILE} | cut -d":" -f2 | sed 's/\"//g' | xargs)
KEYWORDS = $(shell grep "^keywords" ${MDFILE} | cut -d":" -f2 | sed 's/\"//g' | sed 's/[][]//g' | xargs)
TIME_STRING = $(shell date +%B_%Y | tr A-Z a-z | xargs)
AUTHOR_FILENAME = $(shell grep "^author" ${MDFILE} | cut -d":" -f2 | sed 's/\"//g' | xargs | sed 's/ /_/g' | tr A-Z a-z | xargs)


all: html pdf docx rtf

pdf: init
	FILE_NAME="${AUTHOR_FILENAME}_${TIME_STRING}"; \
	echo "Creating $$FILE_NAME.pdf"; \
	sed 's/SUBTITLE/${SUBTITLE}/; s/AUTHOR/${AUTHOR}/g; s/TITLE/${TITLE}/; s/KEYWORDS/${KEYWORDS}/' $(STYLES_DIR)/$(STYLE).tex > /tmp/style.tex; \
	pandoc --standalone --template /tmp/style.tex \
		--from markdown --to context \
		--variable papersize=A4 \
		--output $(OUT_DIR)/$$FILE_NAME.tex markdown/template.md > /dev/null;\
	mtxrun --path=$(OUT_DIR) --result=$$FILE_NAME.pdf --script context $$FILE_NAME.tex > $(OUT_DIR)/context_$$FILE_NAME.log 2>&1; \

html: init
	FILE_NAME="${AUTHOR_FILENAME}_${TIME_STRING}"; \
	echo "Creating $$FILE_NAME.html"; \
	pandoc --standalone --include-in-header $(STYLES_DIR)/$(STYLE).css \
		--lua-filter=pdc-links-target-blank.lua \
		--from markdown --to html \
		--template=$(STYLES_DIR)/$(CUSTOM_HTML_TEMPLATE) \
		--metadata-file=${MDFILE} \
		--output $(OUT_DIR)/$$FILE_NAME.html markdown/template.md; \

docx: init
	FILE_NAME="${AUTHOR_FILENAME}_${TIME_STRING}"; \
	echo "Creating $$FILE_NAME.docx"; \
	pandoc --standalone $$SMART markdown/template.md \
			--metadata-file=${MDFILE} \
		   --output $(OUT_DIR)/$$FILE_NAME.docx; \

rtf: init
	FILE_NAME="${AUTHOR_FILENAME}_${TIME_STRING}"; \
	echo "Creating $$FILE_NAME.rtf"; \
	pandoc --standalone $$SMART markdown/template.md \
		   --metadata-file=${MDFILE} \
		   --output $(OUT_DIR)/$$FILE_NAME.rtf; \

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
