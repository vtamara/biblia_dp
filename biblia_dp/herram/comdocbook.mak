
# Common rules to generate HTML, PostScript and PDF versions of a DocBook document
# Released to the public domain. structio-devel@lists.sourceforge.net

# Variables required

# Tools
#DOCBOOK_XML_DIR Is path of DocBook XML DTD
#XSLTPROC XSLT Processor xsltproc
#XMLLINT XML validator xmllint
#JADE Path to Jade or OpenJade
#JADETEX Path to jadetex
#PDFJADETEX Path to jadetex
#GZIP compressor

# To select which processor use to generate HTML:
# HTML_PROC that can have the values
# dbrep_html_xsltproc or dbrep_html_jade
#
# Of the particular project
# PROYECTO With project name and name of main file (extension $(EXT_DOCBOOK))
# SOURCES Sources including $PROYECTO.$(EXT_DOCBOOK)
# IMAGES 
# HTML_TARGET Target for HTML
# HTML_DIR Directory where HTML will be generated
# XSLT_HTML Custom XSLT for HTML estilohtml.xsl
# PRINT_DIR Directory where PostScript and PDF will be generated
# DSSSL_PRINT DSSSL custom style for printing (estilo.dsl#print)
# DSSSL_HTML DSSSL custom style for HTML generation (estilo.dsl#html)
# DOCBOOK_DSSSL Directory with stylesheets DSSSL for DocBook
# OTHER_HTML Other things to do after generating HTML
# INDEX file name where index will be generated, if NULL no index is generated

valida: $(SOURCES) $(PROYECTO)-4.1.2.$(EXT_DOCBOOK)
	$(XMLLINT) --catalogs --valid $(PROYECTO)-4.1.2.$(EXT_DOCBOOK)

$(PROYECTO)-4.1.2.$(EXT_DOCBOOK): $(PROYECTO).$(EXT_DOCBOOK)
	$(SED) -e "s|DOCTYPE \\([A-Za-z0-9_]*\\) [-\": A-Za-z0-9_/.]*|DOCTYPE \\1 PUBLIC \"-//OASIS//DTD DocBook XML V4.1.2//EN\" \"$(DOCBOOK_XML_DIR)/docbookx.dtd\"|g" $(PROYECTO).$(EXT_DOCBOOK) > $@

$(PROYECTO)-4.1.sgml: $(PROYECTO).$(EXT_DOCBOOK)
	$(SED) -e "s|DOCTYPE \\([A-Za-z0-9_]*\\) [-\": A-Za-z0-9_/.]*|DOCTYPE \\1 PUBLIC \"-//OASIS//DTD DocBook V4.1//EN\"|g" $(PROYECTO).$(EXT_DOCBOOK) > $(PROYECTO)-4.1.sgml

.USE: $(HTML_PROC) $(PS_PROC) $(PDF_PROC)


$(HTML_TARGET): $(HTML_PROC)

# To generate HTML in multiple pages with xsltproc
dbrep_html_xsltproc: $(PROYECTO)-4.1.2.$(EXT_DOCBOOK) $(INDEX) $(SOURCES) $(IMAGES) $(XSLT_HTML) 
	mkdir -p $(HTML_DIR)
	for i in $(IMAGES)  ; do cp $$i $(HTML_DIR)/`basename $$i`; done 
	bp=`pwd`;cd $(HTML_DIR) && rm -f *html && $(XSLTPROC) --catalogs --nonet $$bp/$(XSLT_HTML) $$bp/$(PROYECTO)-4.1.2.$(EXT_DOCBOOK) 
	for i in $(HTML_DIR)/*html; do cp $$i $$i.bak; $(SED) -e "s/�/-/g" $$i.bak > $$i; done
	$(OTHER_HTML)

# To generate HTML in one page with xsltproc
dbrep_html_xsltproc_single: $(PROYECTO)-4.1.2.$(EXT_DOCBOOK) $(INDEX) $(SOURCES) $(IMAGES) $(XSLT_HTML) 
	mkdir -p $(HTML_DIR)
	for i in $(IMAGES) ; do cp $$i $(HTML_DIR)/`basename $$i`; done 
	$(XSLTPROC) --catalogs --nonet $(XSLT_HTML) $(PROYECTO)-4.1.2.$(EXT_DOCBOOK) > $(HTML_TARGET).bak
	$(SED) -e "s/�/-/g" $(HTML_TARGET).bak > $(HTML_TARGET)
	$(OTHER_HTML)


# Possible rule to generate HTML with OpenJade
dbrep_html_jade: $(INDEX) $(SOURCES) $(IMAGES) $(XSLT_HTML) $(PROYECTO)-4.1.2.$(EXT_DOCBOOK)
	mkdir -p $(HTML_DIR)
	for i in $(IMAGES) ; do cp $$i $(HTML_DIR)/`basename $$i`; done 
	-bp=`pwd`;cd $(HTML_DIR) && rm -f *.aux *.log && $(JADE) -V html-backend -D$(DOCBOOK_DSSSL)/html -t sgml -ihtml -d $$bp/$(DSSSL_HTML) $(SGML_XML) $$bp/$(PROYECTO)-4.1.2.$(EXT_DOCBOOK)


$(PROYECTO)-$(PRY_VERSION)_html.tar.gz: $(HTML_TARGET)
	tar cvfz $(PROYECTO)-$(PRY_VERSION)_html.tar.gz $(HTML_DIR)

$(PRINT_DIR)/$(PROYECTO)-$(PRY_VERSION).pdf: $(PRINT_DIR)/$(PROYECTO).pdf
	cp $(PRINT_DIR)/$(PROYECTO).pdf $(PRINT_DIR)/$(PROYECTO)-$(PRY_VERSION).pdf

$(PRINT_DIR)/$(PROYECTO)-$(PRY_VERSION).ps.gz: $(PRINT_DIR)/$(PROYECTO).ps
	cp $(PRINT_DIR)/$(PROYECTO).ps $(PRINT_DIR)/$(PROYECTO)-$(PRY_VERSION).ps
	$(GZIP) $(PRINT_DIR)/$(PROYECTO)-$(PRY_VERSION).ps


$(PRINT_DIR)/$(PROYECTO).pdf: $(PDF_PROC)

dbrep_pdf_ps: $(PRINT_DIR)/$(PROYECTO).ps
	$(PS2PDF) -sPAPERSIZE=$(PAPEL) $(PRINT_DIR)/$(PROYECTO).ps $(PRINT_DIR)/$(PROYECTO).pdf

$(PRINT_DIR)/$(PROYECTO).ps: $(PS_PROC)

dbrep_ps_jade: $(PRINT_DIR)/$(PROYECTO).dvi
	cd $(PRINT_DIR) && dvips -o $(PROYECTO).ps $(PROYECTO).dvi

$(PRINT_DIR)/$(PROYECTO).dvi: $(PRINT_DIR)/$(PROYECTO).tex
	-cd $(PRINT_DIR); $(JADETEX) $(PROYECTO).tex; $(JADETEX) $(PROYECTO).tex; $(JADETEX) $(PROYECTO).tex

$(PRINT_DIR)/$(PROYECTO).tex: $(INDEX) $(SOURCES) $(IMAGES:.png=.eps)  $(PROYECTO)-4.1.2.$(EXT_DOCBOOK)
	mkdir -p $(PRINT_DIR)
	for i in $(IMAGES:.png=.eps) ; do cp -f $$i $(PRINT_DIR)/`basename $$i`; done

	-bp=`pwd`; cd $(PRINT_DIR) && rm -f *.aux *.log && $(JADE) -V tex-backend -D$(DOCBOOK_DSSSL)/print -o $(PROYECTO).tex -t tex -d  $$bp/$(DSSSL_PRINT) $(SGML_XML) $$bp/$(PROYECTO)-4.1.2.$(EXT_DOCBOOK)
	cp $(PRINT_DIR)/$(PROYECTO).tex $(PRINT_DIR)/$(PROYECTO).tex.bak
	$(SED) -e "s/�/{-}/g" $(PRINT_DIR)/$(PROYECTO).tex.bak > $(PRINT_DIR)/$(PROYECTO).tex


$(INDEX): $(INDEX).m
		echo "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>" > $@
	        cat $(INDEX).m >> $@

$(INDEX).m: HTML.index.m
	        perl -S $(COLLATEINDEX) -o $@ HTML.index.m

HTML.index.m: $(PROYECTO)-4.1.2.$(EXT_DOCBOOK) $(SOURCES)
	echo $(COLLATEINDEX);
	if (test ! -f $(INDEX)) then { \
        perl -S $(COLLATEINDEX) -N -o $(INDEX); \
	} fi;
	mkdir -p $(HTML_DIR)
	-cd $(HTML_DIR) && rm -f * && $(JADE) -D .. -D $(DOCBOOK_DSSSL)/html -t sgml -ihtml -V html-index -d docbook.dsl $(SGML_XML) $(PROYECTO)-4.1.2.$(EXT_DOCBOOK) 
	if (test -f html/HTML.index) then { \
	mv html/HTML.index HTML.index.m; } \
	else { \
	touch HTML.index.m; \
	} fi;

.SUFFIXES: .eps .png

.jpg.eps:
	$(CONVERT) $< EPS:$@

.png.eps:
	$(CONVERT) $< EPS:$@

