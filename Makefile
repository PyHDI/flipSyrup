TARGET=./tests/singleport/

.PHONY: all
all: sim

.PHONY: build
build:
	make build -C $(TARGET)

.PHONY: sim
sim:
	make sim -C $(TARGET)

.PHONY: vcs_sim
vcs_sim:
	make vcs_sim -C $(TARGET)

.PHONY: view
view:
	make view -C $(TARGET)

.PHONY: clean
clean:
	make clean -C flipsyrup
	make clean -C ./examples
	make clean -C ./tests
	rm -rf *.pyc __pycache__ flipsyrup.egg-info build dist

.PHONY: release
release:
	pandoc README.md -t rst > README.rst
