# /bin/bash

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
# Rename classes and filenames to correspond with the directory name. For 
# example, if the directory is renamed my-favorite_module, the script will 
# rename the PluginTemplate class to MyFavoriteModule and the source and header 
# to my-favorite_module.cpp and my-favorite_module.h, respectively. 
################################################################################

OLDDIR=plugin-template
OLDCLASS=PluginTemplate
OLDHEADER=plugin-template.h
OLDSOURCE=plugin-template.cpp
OLDOBJECT=plugin_template
OLDPNG=plugin-template.png

DIR=${PWD##*/}
CLASS=$(echo ${DIR} | sed -r 's/(^|_|-)([a-z])/\U\2/g')
HEADER=${DIR}.h
SOURCE=${DIR}.cpp
OBJECT=$(echo ${DIR} | sed -r 's/-/_/g')
PNG=${DIR}.png


echo "${OLDHEADER} -> ${HEADER}"
mv ${OLDHEADER} ${HEADER}

echo "${OLDSOURCE} -> ${SOURCE}"
mv ${OLDSOURCE} ${SOURCE}

echo "${OLDPNG} -> ${PNG}"
mv ${OLDPNG} ${PNG}

echo "${OLDCLASS} -> ${CLASS}"
sed -i "s/${OLDCLASS}/${CLASS}/g" ${HEADER} ${SOURCE}

echo "Editing references to ${OBJECT}, ${SOURCE}, and ${HEADER}"
sed -i "s/${OLDHEADER}/${HEADER}/g" Makefile ${HEADER} ${SOURCE}
sed -i "s/${OLDSOURCE}/${SOURCE}/g" Makefile ${HEADER} ${SOURCE}
sed -i "s/${OLDOBJECT}/${OBJECT}/g" Makefile
