# bano2OsmAnd

This is forked from bano2garmin from PacoTyson at https://github.com/PacoTyson/bano2garmin.
All credits for the original scripts go to Paco.

Shell script that adds BANO addresses (France only) to OpenStreetMap .osm/.o5m/.osm.pbf files before generating OsmAnd maps.<BR>
The prerequisites are GNU awk, [osmconvert](http://wiki.openstreetmap.org/wiki/Osmconvert), [osmfilter](http://wiki.openstreetmap.org/wiki/Osmfilter)

You'll have to edit the script to configure it to your installation : 
- BANODIR=directory where the script will download and store the BANO files
- PBFDIR=directory where the .pbf files are read and written. The read file must follow the Geofabrik naming convention _region_-latest.osm.pbf.
- BINDIR=directory where osmconvert is stored
- SCRIPTDIR=directory where the scripts reside (as you don't want your data mingled with your code)
Please use full datapaths, not relative datapaths



Usage : add-bano-addresses.sh _region_ 
where _region_ can be france or any of those listed on http://download.geofabrik.de/europe/france.html


 
The original script has been tested on Debian Jessie and OS X 10.9.
My scripts have been tested on Debian Jessie and Ubuntu 15.10.
