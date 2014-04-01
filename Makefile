
PLUGIN_NAME = plugin_template

HEADERS = plugin_template.h

SOURCES = plugin_template.cpp\
          moc_plugin_template.cpp\

LIBS = 

### Do not edit below this line ###

include $(shell rtxi_plugin_config --pkgdata-dir)/Makefile.plugin_compile
