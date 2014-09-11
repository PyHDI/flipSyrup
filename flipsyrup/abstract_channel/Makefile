PYTHON=python3
#OPT=-m pdb
MAIN=abstract_channel.py

OUTPUT=out.v

.PHONY: compile
compile:
	$(PYTHON) $(OPT) $(MAIN) -o $(OUTPUT)

.PHONY: test
test:
	iverilog -Wall test.v
	./a.out

.PHONY: clean
clean:
	rm -rf *.pyc __pycache__ $(OUTPUT) a.out uut.vcd
