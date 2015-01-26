# bano4garmin
Shell script that adds BANO addresses (France only) to OpenStreetMap files before generating Garmin maps
The prerequisites are GNU awk and [osmconvert](http://wiki.openstreetmap.org/wiki/Osmconvert)

You'll have to edit the script to configure it to your installation : 
- BANODIR=directory where the script will download and store the BANO files
- PBFDIR=directory where the .pbf files are read and written. The read file must follow the Geofabrik naming convention _region_-latest.osm.pbf.
- BINDIR=directory where osmconvert is stored



Usage : add-bano-addresses.sh _region_ 
where _region_ can be france or any of those listed on http://download.geofabrik.de/europe/france.html


 
It has been tested on Debian Jessie and OS X 10.9.
