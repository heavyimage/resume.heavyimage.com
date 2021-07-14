OUT_DIR=output
IN_DIR=markdown
STYLES_DIR=styles
STYLE=chmduquesne
DATE=$(shell date +%Y)

# User info!
AUTHOR_Q := "Jesse Spielman"
SUBTITLE_Q := "Resume"
KEYWORDS_Q := "Technical Director, ML, Cybersecurity, Reverse Engineering"
TITLE_Q := "${AUTHOR_Q} ${SUBTITLE_Q} ${DATE}"

# Remove Quotes from variables...
# https://stackoverflow.com/a/10430975
AUTHOR := $(subst $\",,$(AUTHOR_Q))
SUBTITLE := $(subst $\",,$(SUBTITLE_Q))
KEYWORDS := $(subst $\",,$(KEYWORDS_Q))
TITLE := $(subst $\",,$(TITLE_Q))


all: html pdf docx rtf

pdf: init
	for f in $(IN_DIR)/*.md; do \
		FILE_NAME=`basename $$f | sed 's/.md//g'`; \
		echo $$FILE_NAME.pdf; \
		sed 's/SUBTITLE/${SUBTITLE}/; s/AUTHOR/${AUTHOR}/g; s/TITLE/${TITLE}/; s/KEYWORDS/${KEYWORDS}/' $(STYLES_DIR)/$(STYLE).tex > /tmp/style.tex; \
		pandoc --standalone --template /tmp/style.tex \
			--from markdown --to context \
			--variable papersize=A4 \
			--output $(OUT_DIR)/$$FILE_NAME.tex $$f > /dev/null; \
		mtxrun --path=$(OUT_DIR) --result=$$FILE_NAME.pdf --script context $$FILE_NAME.tex > $(OUT_DIR)/context_$$FILE_NAME.log 2>&1; \
	done

html: init
	for f in $(IN_DIR)/*.md; do \
		FILE_NAME=`basename $$f | sed 's/.md//g'`; \
		echo $$FILE_NAME.html; \
		pandoc --standalone --include-in-header $(STYLES_DIR)/$(STYLE).css \
			--lua-filter=pdc-links-target-blank.lua \
			--from markdown --to html \
			--output $(OUT_DIR)/$$FILE_NAME.html $$f \
			--metadata pagetitle="$(TITLE)";\
	done

docx: init
	for f in $(IN_DIR)/*.md; do \
		FILE_NAME=`basename $$f | sed 's/.md//g'`; \
		echo $$FILE_NAME.docx; \
		pandoc --standalone $$SMART $$f --output $(OUT_DIR)/$$FILE_NAME.docx; \
	done

rtf: init
	for f in $(IN_DIR)/*.md; do \
		FILE_NAME=`basename $$f | sed 's/.md//g'`; \
		echo $$FILE_NAME.rtf; \
		pandoc --standalone $$SMART $$f --output $(OUT_DIR)/$$FILE_NAME.rtf; \
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
