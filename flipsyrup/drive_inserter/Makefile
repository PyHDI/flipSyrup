PYTHON=python3
#OPT=-m pdb

INSERTER=drive_inserter.py

INCLUDE=-I ../../include/
SRCS=../../input/test/singleport/userlogic.v

OUT=out.v

.PHONY: run
run:
	$(PYTHON) $(OPT) $(INSERTER) $(SRCS) $(INCLUDE) -o $(OUT)

.PHONY: clean
clean:
	rm -rf *.pyc __pycache__ parsetab.py *.out $(OUT)
