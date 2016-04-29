#! /bin/bash

CPPFILE="${PWD##*/}.cpp"
HEADER="${PWD##*/}.h"
SCREENSHOT="${PWD##*/}.png"

README=NEW_README.md

REQUIREMENTS="none"
LIMITATIONS="none"

PLUGIN_NAME=$(cat "${CPPFILE}" | sed -n "s/.*DefaultGUIModel(\"\(.*\)\".*/\1/p")
QWHATSTHIS=$(awk '/setWhatsThis/,/);/' "${CPPFILE}")
DESCRIPTION=$(echo "${QWHATSTHIS}" | tr -d "\n" | tr -d "\t" | tr -d "\"" | \
              sed -n "s/setWhatsThis(\(.*\));/\1/p")
VARS_ARRAY=$(grep -Pzo "(?s)^(\s*)\N*vars\[\].*?{.*?^\1};" "${CPPFILE}")
CATAPULT=$(echo ${VARS_ARRAY} | tr -d '\n' | \
awk ' BEGIN { p=0 } 
{
   for(i=1; i<=length($0); i++)
   {
      test=substr($0, i, 1)
      if(test=="{") {
         p=1
         continue
      }
      if(test=="}") {
         printf("\n")
         p=0;
      }
      if(p==1 && test!="\t") {
         printf("%s", test)
      }
   }
} ')

function PRINT_VARIABLES() {
   LIST=$1
   TYPE=$2
   COUNTER=1
   while read -r LINE; do
      if [[ "$LINE" =~ "$TYPE" ]]; then
         NAME=$(echo ${LINE} | cut -d "," -f1 | sed "s/^[ \t]*//" | sed -e "s/\"//g")
         DESCRIPTION=$(echo ${LINE} | cut -d "," -f2 | sed "s/^[ \t]*//" | sed -e "s/\"//g")
         if [[ "$TYPE" == INPUT ]] || [[ "$TYPE" == OUTPUT ]]; then
            echo "$COUNTER. ${TYPE,,}($((COUNTER-1))) - $NAME : $DESCRIPTION"
         else
            echo "$COUNTER. $NAME - $DESCRIPTION"
         fi
         COUNTER=$((COUNTER+1))
      fi
   done <<< "${LIST}"
}


echo "### ${PLUGIN_NAME}"                          > "${README}"
echo ""                                           >> "${README}"
echo "**Requirements:** ${REQUIREMENTS}"          >> "${README}"
echo "**Limitations:** ${LIMITATIONS}"            >> "${README}"
echo ""                                           >> "${README}"
echo "![${PLUGIN_NAME} GUI](${SCREENSHOT})"       >> "${README}"
echo ""                                           >> "${README}"
echo "<!--start-->"                               >> "${README}"
echo "${DESCRIPTION}"                             >> "${README}"
echo "<!--end-->"                                 >> "${README}"
echo ""                                           >> "${README}"
echo "#### Input"                                 >> "${README}"
echo "$(PRINT_VARIABLES "${CATAPULT}" INPUT)"     >> "${README}"
echo ""                                           >> "${README}"
echo "#### Output"                                >> "${README}"
echo "$(PRINT_VARIABLES "${CATAPULT}" OUTPUT)"    >> "${README}"
echo ""                                           >> "${README}"
echo "#### Parameters"                            >> "${README}"
echo "$(PRINT_VARIABLES "${CATAPULT}" PARAMETER)" >> "${README}"
echo ""                                           >> "${README}"
echo "#### States"                                >> "${README}"
echo "$(PRINT_VARIABLES "${CATAPULT}" STATE)"     >> "${README}"
