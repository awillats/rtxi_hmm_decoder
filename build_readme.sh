#! /bin/bash

################################################################################
# Copyright (C) 2011 Georgia Institute of Technology, University of Utah, 
# Weill Cornell Medical College
#
# This program is free software: you can redistribute it and/or modify it under 
# the terms of the GNU General Public License as published by the Free Software 
# Foundation, either version 3 of the License, or (at your option) any later 
# version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT 
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS 
# FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more 
# details.
# 
# You should have received a copy of the GNU General Public License along with 
# this program.  If not, see <http://www.gnu.org/licenses/>.
################################################################################

################################################################################
# This script will build a README file using a module's source code, assuming 
# the module abstracted from DefaultGUI. In the module directory, run: 
# $ ./build_readme.sh
################################################################################

################################################################################
# Set variables. Assume source code is files have the same name as the parent 
# directory and the output file is called 'NEW_README.md'. 
#
# Manually override the default behaviour as needed. 
################################################################################

CPPFILE="${PWD##*/}.cpp"
HEADER="${PWD##*/}.h"
SCREENSHOT="${PWD##*/}.png"

README=NEW_README.md

REQUIREMENTS=None
LIMITATIONS=None

PLUGIN_NAME=$(cat "${CPPFILE}" | \
              sed -n "s/.*DefaultGUIModel(\"\(.*\)\",.*/\1/p" | \
              sed -e 's/ \([A-Z][a-z]\)/ \1/g')
DESCRIPTION=$(awk '/^[ \t]*setWhatsThis.*/,/\);/' "${CPPFILE}" | \
             tr -d '\n' | sed -n "s/^\s*setWhatsThis(.*\"\(.*\)\");/\1\n/p")
VARS_ARRAY=$(grep -Pzo "(?s)(\s*)\N*vars\[\].*?{.*?\1};" "${CPPFILE}")
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

################################################################################
# Generate the README. The format is intended to be consistent with the pages 
# found on http://rtxi.org/modules. 
################################################################################

echo "### ${PLUGIN_NAME}"                          > "${README}"
echo ""                                           >> "${README}"
echo "**Requirements:** ${REQUIREMENTS}  "        >> "${README}"
echo "**Limitations:** ${LIMITATIONS}  "          >> "${README}"
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
