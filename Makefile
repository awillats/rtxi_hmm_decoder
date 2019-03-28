PLUGIN_NAME = hmm_decoder

#gflag is to enable better debugging
CFLAGS = -g -Wall -Wextra

HEADERS = hmm_decoder.h\
          ../../../module_help/hmmX/hmm/printFuns.hpp\
          ../../../module_help/hmmX/hmm/shuttleFuns.hpp\
          ../../../module_help/hmmX/hmm/hmm_vec.hpp


SOURCES = hmm_decoder.cpp\
          moc_hmm_decoder.cpp\
          ../../../module_help/hmmX/hmm/printFuns.cpp\
          ../../../module_help/hmmX/hmm/shuttleFuns.cpp\
          ../../../module_help/hmmX/hmm/hmm_vec.cpp

LIBS = 

### Do not edit below this line ###

include $(shell rtxi_plugin_config --pkgdata-dir)/Makefile.plugin_compile
