PYTHON=python3
#OPT=-m pdb

INSERTER=run_drive_inserter.py

INCLUDE=-I ../../include/
SRCS=../../tests/singleport/userlogic.v

OUT=out.v

.PHONY: run
run:
	$(PYTHON) $(OPT) $(INSERTER) $(SRCS) $(INCLUDE) -o $(OUT)

.PHONY: clean
clean:
	rm -rf *.pyc __pycache__ parsetab.py *.out $(OUT)
