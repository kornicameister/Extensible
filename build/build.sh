#############################################
#
#  Extensible build script
#  by Extensible, LLC
#
#############################################

# Configuration
# The current version string, substituted into the build path below
VER=extensible-1.6.0-b1

# Default the root to the parent of the current \build folder
EXTENSIBLE_ROOT="`dirname "$0"`/.."

# Output everything here
EXTENSIBLE_OUTPUT=$EXTENSIBLE_ROOT/deploy

# Program start
function usage {
    echo "usage: sh build.sh [-d | --docs]"
    echo
    echo "       -d | --docs: Include updated docs in the output"
    echo
}

while [ "$1" != "" ]; do
    case $1 in
        -d | --docs )           shift
                                docs=1
                                ;;
        -h | --help )           usage
                                exit
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

# Any cleanup that needs to happen prior to the build
rm -rf $EXTENSIBLE_OUTPUT/$VER
rm $EXTENSIBLE_ROOT/resources/css/extensible-all.css

# Build it
java -jar $EXTENSIBLE_ROOT/build/JSBuilder2.jar --projectFile $EXTENSIBLE_ROOT/build/extensible.jsb2 --homeDir $EXTENSIBLE_OUTPUT

# Copy the Extensible class definition to /lib as extensible-bootstrap.js for dynamic loading support
cp $EXTENSIBLE_ROOT/src/Extensible.js $EXTENSIBLE_OUTPUT/$VER/lib/extensible-bootstrap.js

# Copy the deploy files back into dev so that the samples get the latest code
echo Updating dev...
cp $EXTENSIBLE_OUTPUT/$VER/lib/extensible-bootstrap.js $EXTENSIBLE_ROOT/lib
cp $EXTENSIBLE_OUTPUT/$VER/lib/extensible-all.js $EXTENSIBLE_ROOT/lib
cp $EXTENSIBLE_OUTPUT/$VER/lib/extensible-all-debug.js $EXTENSIBLE_ROOT/lib
cp $EXTENSIBLE_OUTPUT/$VER/resources/css/extensible-all.css $EXTENSIBLE_ROOT/resources/css

# Copy other resource files to output
cp $EXTENSIBLE_ROOT/Extensible-config.js $EXTENSIBLE_OUTPUT/$VER
cp $EXTENSIBLE_ROOT/lib/extensible-1.0-compat.js $EXTENSIBLE_OUTPUT/$VER/lib
cp $EXTENSIBLE_ROOT/*.html $EXTENSIBLE_OUTPUT/$VER
cp $EXTENSIBLE_ROOT/*.txt $EXTENSIBLE_OUTPUT/$VER
cp $EXTENSIBLE_ROOT/*.md $EXTENSIBLE_OUTPUT/$VER

# Docs
if [ "$docs" = "1" ]; then
    echo Generating docs...
    
    # This is the old jsbuilder command, preserved for reference only:
    # java -jar $EXTENSIBLE_ROOT/build/ext-doc.jar -p $EXTENSIBLE_ROOT/build/extensible.xml -o $EXTENSIBLE_OUTPUT/$VER/docs -t $EXTENSIBLE_ROOT/build/template/ext/template.xml
    
    # The docs have now been converted to JSDuck. This assumes that JSDuck is installed
    # correctly and available in the system path.
    # - Installation: https://github.com/senchalabs/jsduck/wiki/Installation
    # - Configuring this command: jsduck --help
    jsduck $EXTENSIBLE_ROOT/src --output $EXTENSIBLE_OUTPUT/$VER/docs --seo --builtin-classes \
        --message="Note that these docs have not yet been finalized for 1.6.0" \
        --title="Extensible Docs" \
        --footer="<a href='http://ext.ensible.com/'>Ext.ensible.com</a>" \
        --warnings=-all \
        --exclude=$EXTENSIBLE_ROOT/src/calendar/dd/CalendarScrollManager.js \
        --ignore-html=locale,debug
fi

echo All done!
