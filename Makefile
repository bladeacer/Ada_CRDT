.PHONY: all build check clean test

ADA_FLAGS := -gnatwa -gnatyg -gnat12 -gnata -gnatwe
SRC_DIR   := src
OBJ_DIR   := obj
TEST_DIR  := test

SOURCES := \
  $(SRC_DIR)/ardt.ads \
  $(SRC_DIR)/ardt-core.ads \
  $(SRC_DIR)/ardt-core.adb \
  $(SRC_DIR)/ardt-pn_counters.ads \
  $(SRC_DIR)/ardt-pn_counters.adb \
  $(SRC_DIR)/ardt-lww_element_sets.ads \
  $(SRC_DIR)/ardt-lww_element_sets.adb \
  $(SRC_DIR)/ardt-rga.ads \
  $(SRC_DIR)/ardt-rga.adb \
  $(SRC_DIR)/ardt-rgas.ads \
  $(SRC_DIR)/ardt-rgas.adb

TEST_SOURCES := \
  $(TEST_DIR)/test_crdt.adb

all: build

$(OBJ_DIR):
	mkdir -p $(OBJ_DIR)

check: $(SOURCES)
	gnatcheck $(ADA_FLAGS) -files=$^ -a -rules -rule+RA_XX_001

build: $(OBJ_DIR) $(SOURCES)
	gnatmake -c $(ADA_FLAGS) -P ardt.gpr

test: $(OBJ_DIR) $(TEST_SOURCES)
	gnatmake -o $(OBJ_DIR)/test_crdt \
	  $(ADA_FLAGS) \
	  -I$(SRC_DIR) \
	  $(TEST_SOURCES) \
	  -D $(OBJ_DIR)
	./$(OBJ_DIR)/test_crdt

clean:
	rm -rf $(OBJ_DIR)
	rm -f *.o *.ali test_crdt b~*.ad?
