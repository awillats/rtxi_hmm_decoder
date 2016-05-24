# /bin/bash

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

echo "Editing Makefile"
sed -i "s/${OLDHEADER}/${HEADER}/g" Makefile
sed -i "s/${OLDSOURCE}/${SOURCE}/g" Makefile
sed -i "s/${OLDOBJECT}/${OBJECT}/g" Makefile
