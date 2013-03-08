#
# stefan.sobernig@wu.ac.at
#

# 1) include the TEA-generated Makefile
include ../Makefile

UNAME = $(shell uname)
TYPECHEF_DIR = $(shell pwd)

ifndef TYPECHEF_JAR
	TYPECHEF_JAR = ../TypeChef/TypeChef-0.3.3.jar
endif

TYPECHEF_DIR = $(shell pwd)
TEA_DIR = $(shell cd .. && pwd)

# 2) Process some TEA macros into a convenient form ...
TYPECHEF_INCL = $(INCLUDES)
TYPECHEF_CHECKFILES = $(PKG_SOURCES)
TYPECHEF_CHECKFILES_EXP = $(TYPECHEF_CHECKFILES:%=$(TEA_DIR)/$(src_generic_dir)/%)
TYPECHEF_PCFILES = $(TYPECHEF_CHECKFILES_EXP:%.c=%.pc)
TYPECHEF_CLEANFILES = 	$(TYPECHEF_CHECKFILES_EXP:%.c=%.c.exp) \
			$(TYPECHEF_CHECKFILES_EXP:%.c=%.c.xml) \
			$(TYPECHEF_PCFILES) \
			$(TYPECHEF_CHECKFILES_EXP:%.c=%.pi) \
			$(TYPECHEF_CHECKFILES_EXP:%.c=%.pi.dbgSrc) \
			$(TYPECHEF_CHECKFILES_EXP:%.c=%.pi.macroDbg) \
			$(TYPECHEF_CHECKFILES_EXP:%.c=%.c.ast)

TYPECHEF_FEAT = $(TYPECHEF_DIR)/$(PACKAGE_NAME).feat
TYPECHEF_FM = $(TYPECHEF_DIR)/$(PACKAGE_NAME).fm
TYPECHEF_PCONF = $(TYPECHEF_DIR)/$(PACKAGE_NAME)-partial.h

ifeq ($(UNAME), Darwin)
# Can we generalize this into some gcc call?
TYPECHEF_INCL += -I /usr/llvm-gcc-4.2/bin/../lib/gcc/i686-apple-darwin11/4.2.1/include	
TYPECHEF_PLATFORM_HEADER = -h ../TypeChef/host/platform-darwin-wrapper.h
endif

# 3) Package-specific includes? 

#
# Note: Only necessary because ASM is not
# part of TEA build process (yet)
#

TYPECHEF_INCL += -I ./generic/asm/

%.pc :
	@(cd .. && touch $@)

$(TYPECHEF_CHECKFILES) : $(TYPECHEF_PCFILES)
$(TYPECHEF_CHECKFILES) : $(TYPECHEF_CHECKFILES_EXP)
	(cd .. && java 	-Xmx2048M -Xss10m \
		-jar $(TYPECHEF_JAR) \
		$(TYPECHEF_PLATFORM_HEADER) \
		--typecheck \
	        $(TYPECHEF_INCL) \
		--openFeat=$(TYPECHEF_FEAT) \
		--featureModelFExpr=$(TYPECHEF_FM) \
		--writePI \
		--recordTiming \
		--lexdebug \
		--errorXML \
		--partialConfiguration=$(TYPECHEF_PCONF) $(TEA_DIR)/$(src_generic_dir)/$@)


typecheck: $(TYPECHEF_CHECKFILES)

typechef-clean:
	echo "Deleting $(TYPECHEF_CLEANFILES)"
	@(cd .. && rm -rf $(TYPECHEF_CLEANFILES))