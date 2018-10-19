# $Id$
TOP_DIR := ..
include $(TOP_DIR)/Makefile.include

PLUGINS :=          \
   compat_digest.plug \
   demo.plug        \
   demofiles.plug   \
   file2pacDep.plug \
   nodoc.plug       \
   set_tag.plug     \
   uniq.plug        \
   un_prelink.plug  \
   unset_tag.plug   \
                    \

SCRIPTS :=        \
   compat_digest.sh \
   demo.sh        \
   demofiles.sh   \
   file2pacDep.sh \
   nodoc.sh       \
   set_tag.sh     \
   uniq.sh        \
   un_prelink.sh  \
   unset_tag.sh   \
                  \

MANPAGES_BASE := $(addsuffix .1rrp,$(PLUGINS))

MANPAGES := $(foreach lang,$(LANGS),$(addprefix man/$(lang)/,$(MANPAGES_BASE)))
MANPAGES_DEF := $(foreach lang,$(LANG_DEF),$(addprefix man/$(lang)/,$(MANPAGES_BASE)))
HTML_PAGES=$(MANPAGES_DEF:.1rrp=.1.html)

MANPAGES_SRC := $(addsuffix .in,$(MANPAGES))

SOURCES :=         \
   $(PLUGINS)	   \
   $(SCRIPTS)      \
   $(MANPAGES_SRC) \
   Makefile        \

all: $(MANPAGES)

$(MANPAGES): %: %.in $(TOP_DIR)/Version
	$(MakeManPage)

man: $(MANPAGES)

install:
	$(MKDIR)                   $(TARGET_PLUGIN)
	$(INSTALL_RO)  $(PLUGINS)  $(TARGET_PLUGIN)
	$(INSTALL_RUN) $(SCRIPTS)  $(TARGET_PLUGIN)
	$(InstallManPages)

clean:
	$(RM) $(MANPAGES)
	$(RM) $(HTML_PAGES)

tar_names:
	@echo $(addprefix plugins/,$(SOURCES))

$(HTML_PAGES): $(MANPAGES_DEF)

html: $(HTML_PAGES)
	cp $(HTML_PAGES) $(TOP_DIR)/../web
