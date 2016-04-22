#! /bin/bash

CPPFILE=
HEADER=
README=NEW_README.md

REQUIREMENTS=
LIMITATIONS=

PLUGIN_NAME=$(cat "$CPPFILE" | sed -n "s/.*DefaultGUIModel(\"\(.*\)\".*/\1/p")
DESCRIPTION=$(cat "$CPPFILE" | sed -n "s/.*setWhatsThis(\"\(.*\)\".*/\1/p")

echo "### ${PLUGIN_NAME}" > "$README"
echo "" >> "$README"
echo "\*\*Requirements:\*\*\ ${REQUIREMENTS}" >> "$README"
echo "\*\*Limitations:\*\*\ ${LIMITATIONS}" >> "$README"
echo "" >> "$README"
echo "<!--start-->" >> "$README"
echo "${DESCRIPTION}" >> "$README"
echo "<!--end-->" >> "$README"
echo "" >> "$README"
echo "#### Input" >> "$README"
echo "" >> "$README"
echo "#### Output" >> "$README"
echo "" >> "$README"
echo "#### Parameters" >> "$README"
echo "" >> "$README"
echo "#### States" >> "$README"
