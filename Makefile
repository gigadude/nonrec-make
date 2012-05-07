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

.PHONY: all clean clean_all clean_tree

# By default build only targets from this directory (and its dependencies)
.DEFAULT_GOAL := tree_$(RUNDIR)
# A shortcut to build whole subtree
tree : tree_$(RUNDIR)
# A shortcut to build just this dir
tree : dir_$(RUNDIR)

clean : clean_$(RUNDIR)
clean_tree : clean_tree_$(RUNDIR)

INSTALLABLES = $(filter-out %.o,$(call subtree_tgts,$(d)))

install :
	@echo "example install libs: $(filter %.$(SOEXT),$(INSTALLABLES)) -> $(TOP)/$(HOST_ARCH)/lib"
	@echo "example install exes: $(filter-out %.a %.$(SOEXT),$(INSTALLABLES)) -> $(TOP)/$(HOST_ARCH)/bin"

include $(MK)/header.mk
include $(TOP)/Rules.top
include $(MK)/footer.mk

# This is just a convenience - to let you know when make has stopped
# interpreting make files and started their execution.
$(info Rules generated...)
