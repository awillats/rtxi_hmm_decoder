#! /bin/bash

CPPFILE=plugin-template.cpp
HEADER=plugin-template.h
README=NEW_README.md

REQUIREMENTS="none"
LIMITATIONS="none"

PLUGIN_NAME=$(cat "${CPPFILE}" | sed -n "s/.*DefaultGUIModel(\"\(.*\)\".*/\1/p")
DESCRIPTION=$(cat "${CPPFILE}" | sed -n "s/.*setWhatsThis(\"\(.*\)\".*/\1/p")
VARS_ARRAY=$(grep -Pzo "(?s)^(\s*)\N*vars\[\].*?{.*?^\1}" "${CPPFILE}")


echo "### ${PLUGIN_NAME}"                 > "${README}"
echo ""                                  >> "${README}"
echo "**Requirements:** ${REQUIREMENTS}" >> "${README}"
echo "**Limitations:** ${LIMITATIONS}"   >> "${README}"
echo ""                                  >> "${README}"
echo "<!--start-->"                      >> "${README}"
echo "${DESCRIPTION}"                    >> "${README}"
echo "<!--end-->"                        >> "${README}"
echo ""                                  >> "${README}"
echo "#### Input"                        >> "${README}"
echo ""                                  >> "${README}"
echo "#### Output"                       >> "${README}"
echo ""                                  >> "${README}"
echo "#### Parameters"                   >> "${README}"
echo ""                                  >> "${README}"
echo "#### States"                       >> "${README}"
