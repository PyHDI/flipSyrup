PYTHON=python3
#OPT=-m pdb

CONVERTER=run_rtl_converter.py

INCLUDE=-I ../../include/
SRCS=../../tests/singleport/userlogic.v
TOPMODULE=userlogic

OUT=out.v

.PHONY: run
run:
	$(PYTHON) $(OPT) $(CONVERTER) $(SRCS) $(INCLUDE) -t $(TOPMODULE) -o $(OUT)

.PHONY: clean
clean:
	rm -rf *.pyc __pycache__ parsetab.py *.out $(OUT)
