CC := gcc
SRCDIR := .
TARGET := ../bin/test

SRCEXT := c
SOURCES := $(shell find $(SRCDIR) -type f -name "*.$(SRCEXT)")
CFLAGS := -g -Wall -std=c11
LIB :=
INC := 

run: $(TARGET)
	@$(TARGET)

$(TARGET): $(SOURCES)
	@echo "Building..."
	@echo " $(CC) $(CFLAGS) $^ $(INC) $(LIB) -o $(TARGET)"; $(CC) $(CFLAGS) $^ $(INC) $(LIB) -o $(TARGET)
	@echo "Completed"
	@echo "------------------------------------------------------ "

clean:
	@echo "Cleaning Tests..."; 
	@echo " $(RM) -r $(TARGET)"; $(RM) -r $(TARGET)

.PHONY: clean run