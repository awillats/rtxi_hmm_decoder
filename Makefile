PLUGIN_NAME = plugin_template

HEADERS = plugin-template.h

SOURCES = plugin-template.cpp\
          moc_plugin-template.cpp\

LIBS = 

### Do not edit below this line ###

include $(shell rtxi_plugin_config --pkgdata-dir)/Makefile.plugin_compile
