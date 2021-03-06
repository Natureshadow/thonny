#!/bin/bash
set -e

# Should be run after new thonny package is uploaded to PyPi

PREFIX=$HOME/thonny_template_build_37
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"


# prepare working folder #########################################################
rm -rf build
mkdir -p build


# copy template #################################################
cp -R -H $PREFIX/Thonny.app build

# update launch script (might have changed after last create_base_bundle.sh) #####################
cp $SCRIPT_DIR/Thonny.app.initial_template/Contents/MacOS/thonny \
    build/Thonny.app/Contents/MacOS

FRAMEWORKS=build/Thonny.app/Contents/Frameworks
PYTHON_CURRENT=$FRAMEWORKS/Python.framework/Versions/3.7/

# install deps #####################################################
$PYTHON_CURRENT/bin/python3.7 -s -m pip install --no-cache-dir asttokens==1.1.*
$PYTHON_CURRENT/bin/python3.7 -s -m pip install --no-cache-dir parso==0.5.*
$PYTHON_CURRENT/bin/python3.7 -s -m pip install --no-cache-dir jedi==0.14.*
$PYTHON_CURRENT/bin/python3.7 -s -m pip install --no-cache-dir --no-binary mypy mypy==0.720
$PYTHON_CURRENT/bin/python3.7 -s -m pip install --no-cache-dir pylint==2.3.*
$PYTHON_CURRENT/bin/python3.7 -s -m pip install docutils==0.15.*
$PYTHON_CURRENT/bin/python3.7 -s -m pip install pyserial==3.4

# install certifi #####################################################
$PYTHON_CURRENT/bin/python3.7 -s -m pip install certifi

# install thonny #####################################################
$PYTHON_CURRENT/bin/python3.7 -s -m pip install --pre --no-cache-dir thonny
rm $PYTHON_CURRENT/bin/thonny # because this contains absolute paths

# clean unnecessary stuff ###################################################

# delete all *.h files except one
#mv $PYTHON_CURRENT/include/python3.7m/pyconfig.h $SCRIPT_DIR # pip needs this
#find $FRAMEWORKS -name '*.h' -delete
#mv $SCRIPT_DIR/pyconfig.h $PYTHON_CURRENT/include/python3.7m # put it back

#find $FRAMEWORKS -name '*.a' -delete

rm -rf $FRAMEWORKS/Tcl.framework/Versions/8.6/Tcl_debug
rm -rf $FRAMEWORKS/Tk.framework/Versions/8.6/Tk_debug
rm -rf $FRAMEWORKS/Tk.framework/Versions/8.6/Resources/Scripts/demos
rm -rf $FRAMEWORKS/Tcl.framework/Versions/8.6/Resources/Documentation
rm -rf $FRAMEWORKS/Tk.framework/Versions/8.6/Resources/Documentation

find $PYTHON_CURRENT/lib -name '*.pyc' -delete
find $PYTHON_CURRENT/lib -name '*.exe' -delete
rm -rf $PYTHON_CURRENT/Resources/English.lproj/Documentation

rm -rf $PYTHON_CURRENT/share
rm -rf $PYTHON_CURRENT/lib/python3.7/test
rm -rf $PYTHON_CURRENT/lib/python3.7/idlelib


rm -rf $PYTHON_CURRENT/lib/python3.7/site-packages/pylint/test
rm -rf $PYTHON_CURRENT/lib/python3.7/site-packages/mypy/test

# clear bin because its scripts have absolute paths
mv $PYTHON_CURRENT/bin/python3.7 $SCRIPT_DIR # save python exe
rm -rf $PYTHON_CURRENT/bin/*
mv $SCRIPT_DIR/python3.7 $PYTHON_CURRENT/bin/

# create pip
# NB! check that pip.sh refers to correct executable!
cp $SCRIPT_DIR/../pip.sh $PYTHON_CURRENT/bin/pip3.7

# create linkns ###############################################################
cd $PYTHON_CURRENT/bin
ln -s python3.7 python3
ln -s pip3.7 pip3
cd $SCRIPT_DIR




# copy the token signifying Thonny-private Python
cp thonny_python.ini $PYTHON_CURRENT/bin 


# Replace Python.app Info.plist to get name "Thonny" to menubar
cp -f $SCRIPT_DIR/Python.app.plist $PYTHON_CURRENT/Resources/Python.app/Contents/Info.plist

# version info ##############################################################
VERSION=$(<$PYTHON_CURRENT/lib/python3.7/site-packages/thonny/VERSION)
ARCHITECTURE="$(uname -m)"
VERSION_NAME=thonny-$VERSION-$ARCHITECTURE 


# set version ############################################################
sed -i.bak "s/VERSION/$VERSION/" build/Thonny.app/Contents/Info.plist
rm -f build/Thonny.app/Contents/Info.plist.bak

# sign frameworks and app ##############################
codesign -s "Aivar Annamaa" --timestamp --keychain ~/Library/Keychains/login.keychain build/Thonny.app/Contents/Frameworks/Python.framework
codesign -s "Aivar Annamaa" --timestamp --keychain ~/Library/Keychains/login.keychain build/Thonny.app

# add readme #####################################################################
cp readme.txt build

# create dmg #####################################################################
mkdir -p dist
FILENAME=dist/thonny-${VERSION}.dmg
rm -f $FILENAME
hdiutil create -srcfolder build -volname "Thonny $VERSION" $FILENAME
hdiutil internet-enable -yes $FILENAME

# sign dmg ######################
codesign -s "Aivar Annamaa" --keychain ~/Library/Keychains/login.keychain $FILENAME

# xxl ####################################################################################
$PYTHON_CURRENT/bin/python3.7 -s -m pip install guizero
$PYTHON_CURRENT/bin/python3.7 -s -m pip install gpiozero
$PYTHON_CURRENT/bin/python3.7 -s -m pip install requests
$PYTHON_CURRENT/bin/python3.7 -s -m pip install pillow
$PYTHON_CURRENT/bin/python3.7 -s -m pip install scipy
$PYTHON_CURRENT/bin/python3.7 -s -m pip install matplotlib
$PYTHON_CURRENT/bin/python3.7 -s -m pip install numpy

$PYTHON_CURRENT/bin/python3.7 -s -m pip install pgzero
$PYTHON_CURRENT/bin/python3.7 -s -m pip install pygame

$PYTHON_CURRENT/bin/python3.7 -s -m pip install flask

$PYTHON_CURRENT/bin/python3.7 -s -m pip install pytest

$PYTHON_CURRENT/bin/python3.7 -s -m pip install colorama
$PYTHON_CURRENT/bin/python3.7 -s -m pip install birdseye
$PYTHON_CURRENT/bin/python3.7 -s -m pip install beautifulsoup4

#$PYTHON_CURRENT/bin/python3.7 -s -m pip install pygal
#$PYTHON_CURRENT/bin/python3.7 -s -m pip install easygui
#$PYTHON_CURRENT/bin/python3.7 -s -m pip install pysimplegui
#$PYTHON_CURRENT/bin/python3.7 -s -m pip install pykkar

#$PYTHON_CURRENT/bin/python3.7 -s -m pip install pandas
#$PYTHON_CURRENT/bin/python3.7 -s -m pip install lxml
#$PYTHON_CURRENT/bin/python3.7 -s -m pip install openpyxl
#$PYTHON_CURRENT/bin/python3.7 -s -m pip install xlrd

#$PYTHON_CURRENT/bin/python3.7 -s -m pip install vpython
#$PYTHON_CURRENT/bin/python3.7 -s -m pip uninstall notebook

find $PYTHON_CURRENT/lib -name '*.pyc' -delete
find $PYTHON_CURRENT/lib -name '*.exe' -delete

# create dmg #####################################################################
PLUS_FILENAME=dist/thonny-xxl-${VERSION}.dmg
rm -f $PLUS_FILENAME
hdiutil create -srcfolder build -volname "Thonny XXL $VERSION" $PLUS_FILENAME
hdiutil internet-enable -yes $PLUS_FILENAME

# sign dmg ######################
codesign -s "Aivar Annamaa" --keychain ~/Library/Keychains/login.keychain $PLUS_FILENAME


# clean up #######################################################################
#rm -rf build
