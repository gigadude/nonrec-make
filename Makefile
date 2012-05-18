# When I'm using default shell on Cygwin $(shell pwd) does not give the
# same result as $(shell echo $$PWD) or $(shell echo `pwd`).  It gives
# me path with symbolic links resolved whereas the later two do not do
# that.  I prefer unresolved version and since simple $(shell pwd) looks
# nicer than other two I'm sticking with bash :).
SHELL := /bin/bash
RUNDIR := $(shell pwd)
ifndef TOP
TOP := $(shell rd=$(RUNDIR); top=$$rd; \
               until [ -r $$top/Rules.top ]; do \
                 oldtop=$$top; \
                 cd ..; top=`pwd`; \
                 if [ $$oldtop = $$top ]; then \
                   top=$$rd; break; \
                 fi; \
               done; \
               echo $$top)
endif

MK := $(TOP)/mk

.PHONY: dir tree all clean clean_all clean_tree dist_clean

# Default target when nothing is given on the command line.  Reasonable
# options are:
# "dir"  - updates only targets from current directory and its dependencies
# "tree" - updates targets (and their dependencies) in whole subtree
#          starting at current directory
# "all"  - updates all targets in the project
.DEFAULT_GOAL := tree

dir : dir_$(RUNDIR)
	@echo "Done building $(RUNDIR) $(BUILDMODES)"

tree : tree_$(RUNDIR)
	@echo "Done building $(RUNDIR)/... $(BUILDMODES)"

all : tree_$(TOP)
	@echo "Done building $(TOP)/... $(BUILDMODES)"

clean_dir : clean_$(RUNDIR)
clean_tree : clean_tree_$(RUNDIR)

clean : clean_$(.DEFAULT_GOAL)

# BUILDMODES can be one or more of these flavors
BUILD_FLAVORS := release debug prof

# specifying one or more build flavors on the command-line switches to building
# that flavor in future builds which omit any mode explicitly
BUILDMODES = $(filter $(BUILD_FLAVORS),$(MAKECMDGOALS))

.set_buildmode_prefs : $(.DEFAULT_GOAL)
	@echo "Build preference set to ($(BUILDMODES))"

.PHONY: $(BUILD_FLAVORS)

$(BUILD_FLAVORS) : .set_buildmode_prefs
	@true

# remember the last requested build mode as a sticky setting
ifneq ($(strip $(BUILDMODES)),)
$(eval $(shell echo "BUILDMODES := $(BUILDMODES)" > $(MK)/buildmodes.mk))
endif

# attempt to include the sticky buildmode setting, default to all modes
# (could use the same trick for verbose etc.)
-include $(MK)/buildmodes.mk
ifeq ($(strip $(BUILDMODES)),)
BUILDMODES := $(BUILD_FLAVORS)
endif

include $(MK)/header.mk
include $(TOP)/Rules.top
include $(MK)/footer.mk

# Optional final makefile where you can specify additional targets
-include $(TOP)/final.mk

# This is just a convenience - to let you know when make has stopped
# interpreting make files and started their execution.
$(info Rules generated...)
