PYTHON=python3
#OPT=-m pdb
MAIN=abstract_memory.py

INPUT=sample.config
OUTPUT=out.v

.PHONY: compile
compile:
	$(PYTHON) $(OPT) $(MAIN) $(INPUT) -o $(OUTPUT)

.PHONY: clean
clean:
	rm -rf *.pyc __pycache__ $(OUTPUT)
