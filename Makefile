# Implemented from http://hiltmon.com/blog/2013/07/03/a-simple-c-plus-plus-project-structure/
 
CC := gcc # This is the main compiler
SRCDIR := src
BUILDDIR := build
LIBDIR := lib
TESTDIR := test
TARGET := bin/aurora
 
SRCEXT := c
SOURCES := $(shell find $(SRCDIR) -type f -name "*.$(SRCEXT)")
OBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SOURCES:.$(SRCEXT)=.o))
CFLAGS := -g -Wall -std=c11
LIB := -L $(LIBDIR) -framework OpenGL
INC := -I include

$(TARGET): $(OBJECTS)
	@echo "Linking..."
	@echo " $(CC) $^ -o $(TARGET) $(LIB)"; $(CC) $^ -o $(TARGET) $(LIB)
	@echo "Completed"
	@echo "------------------------------------------------------ "

$(BUILDDIR)/%.o: $(SRCDIR)/%.$(SRCEXT)
	@echo "Building..."
	@mkdir -p $(dir $@)
	@echo " $(CC) $(CFLAGS) $(INC) -c -o $@ $<"; $(CC) $(CFLAGS) $(INC) -c -o $@ $<

clean:
	@echo "Cleaning..."; 
	@echo " $(RM) -r $(BUILDDIR) $(TARGET)"; $(RM) -r $(BUILDDIR) $(TARGET)
	@cd $(TESTDIR); make clean

# Tests
test:
	@cd $(TESTDIR); make

.PHONY: clean test