PLUGIN_NAME = hmm_decoder

HEADERS = hmm_decoder.h\
          ../../../module_help/StAC_rtxi/hmmFuns.hpp\
          ../../../module_help/StAC_rtxi/hmm_tests/hmm_vec.hpp


SOURCES = hmm_decoder.cpp\
          moc_hmm_decoder.cpp\
          ../../../module_help/StAC_rtxi/hmmFuns.cpp\
          ../../../module_help/StAC_rtxi/hmm_tests/hmm_vec.cpp\


LIBS = 

### Do not edit below this line ###

include $(shell rtxi_plugin_config --pkgdata-dir)/Makefile.plugin_compile
