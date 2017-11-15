# Implemented from http://hiltmon.com/blog/2013/07/03/a-simple-c-plus-plus-project-structure/
 
CC := gcc # This is the main compiler
SRCDIR := src
BUILDDIR := build
 
SRCEXT := c
SOURCES := $(shell find $(SRCDIR) -type f -name "*.$(SRCEXT)")
OBJECTS := $(patsubst $(SRCDIR)/%,$(BUILDDIR)/%,$(SOURCES:.$(SRCEXT)=.o))
CFLAGS := -g -Wall -std=c11 -Wno-deprecated-declarations

# Get the current platform, and based on that, use different library search paths
UNAME := $(shell uname)
ifeq ($(UNAME), CYGWIN_NT-6.1)
LIB := -lopengl32 -lglut64
TARGET := bin/Aurora.exe
else
LIB := -framework OpenGL -framework GLUT
TARGET := bin/Aurora
endif

INC := 

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

.PHONY: clean