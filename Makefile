PLUGIN_NAME := hmm_decoder

HOME_DIR := /home/stanleyrtxi/CodeRepository/adam_RTXI#$(WILLATS_RTXI_HOME)
HELP_DIR := $(HOME_DIR)/module_help
HMM_DIR := $(HELP_DIR)/hmmX/hmm

#gflag is to enable better debugging
CFLAGS = -g -Wall -Wextra -I/home/adam/RTXI/module_help/hmmX/hmm

HEADERS = hmm_decoder.h\
	$(HMM_DIR)/printFuns.hpp\
	$(HMM_DIR)/shuttleFuns.hpp\
	$(HMM_DIR)/hmm_vec.hpp


SOURCES = hmm_decoder.cpp\
          moc_hmm_decoder.cpp\
	  $(HMM_DIR)/printFuns.cpp\
          $(HMM_DIR)/shuttleFuns.cpp\
          $(HMM_DIR)/hmm_vec.cpp\

LIBS =

CXXFLAGS := $(CXXFLAGS) -I$(HMM_DIR)

### Do not edit below this line ###

include $(shell rtxi_plugin_config --pkgdata-dir)/Makefile.plugin_compile

print-% : ; @echo $* = $($*)
