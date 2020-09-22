PDFLATEX = pdflatex
LEDGER = ledger
HLEDGER = hledger
BOEC = boec
PS2PDF = ps2pdf
PRINTREPORT = print-report
PDFCAT = pdfcat
SEQDIAG = seqdiag
DIAG_FLAGS = --no-transparency

%.ledger.tex: template.tex %.xml
	$(BOEC) --template $< < $(filter-out $<,$^ ) > $@

%.xml: %.journal
	$(LEDGER) -f $< xml --output $@

%.ledger.pdf: %.ledger.tex
	$(PDFLATEX) $<
	rm -f *.aux *.log

%.report.pdf: %.report.ps
	$(PS2PDF) $<

%.bs.report.ps: %.journal
	$(HLEDGER) bs -f $< -M -B | $(PRINTREPORT) > $@

%.is.report.ps: %.journal
	$(HLEDGER) is -f $< -M | $(PRINTREPORT) > $@

%.cf.report.ps: %.journal
	$(HLEDGER) cf -f $< -M not:inventory | $(PRINTREPORT) > $@

%.inventory.report.ps: %.journal
	$(HLEDGER) bal -f $< -M --cumulative inventory | sed -e 's/Ending balances/Inventory/' | $(PRINTREPORT) > $@

%.pdf: %.ledger.pdf %.is.report.pdf %.bs.report.pdf %.cf.report.pdf %.inventory.report.pdf
	$(PDFCAT) $^ > $@

%.png: %.diag
	$(SEQDIAG) $(filter-out $<,$^ ) -o $@ $(DIAG_FLAGS) $<

all: $(addsuffix .pdf, $(basename $(wildcard *.journal))) $(addsuffix .png, $(basename $(wildcard diagrams/*.diag)))

.PHONY: clean
clean :
	rm -f *.pdf *.log *.aux *.png
