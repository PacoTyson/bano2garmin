#!/bin/bash

set -eu

BANODIR=/opt/OpenStreetMap/Bano-Address-France/BANODIR
PBFDIR=/opt/OpenStreetMap/Bano-Address-France/PBFDIR
BINDIR=/opt/software/OsmAnd-UKpostcodes/tools
SCRIPTDIR=/opt/OpenStreetMap/Bano-Address-France/bano2garmin

UPDATE=0
PROCESS=0

while getopts ":up" OPT; do
	case $OPT in
		u)
			UPDATE=1
			;;
		p)
			PROCESS=1
			;;
		\?)
			echo "Ignoring invalid option: -$OPTARG" >&2
			;;
	esac
done


if [ "$#" -ne $OPTIND ];
then
    echo "Usage : $0 [-u] [-p] <region>"
    echo "where region can be france or any of those listed on http://download.geofabrik.de/europe/france.html"
    echo "-u : updates the BANO files"
    echo "-p : proceeds to merge BANO addresses to OSM data"
    echo "If no option is given, -u and -p are implied"
    exit 1
fi

# No option given means -u -p
if [ $UPDATE -eq 0 -a $PROCESS -eq 0 ] ;
then
    UPDATE=1
    PROCESS=1
fi


MAP="${@: -1}"


if [ ! -e $PBFDIR/$MAP-latest.osm.pbf ]
then
    echo "File not found : $PBFDIR/$MAP-latest.osm.pbf"
    exit 2
fi


DEPTS=$(grep $MAP "$SCRIPTDIR"/BANO-region-departements-mapping.txt | cut -f 2 | sed s/,/\ /g)

if [ $UPDATE -eq 1 ];
then
    echo "Updating..."
    cd $BANODIR
    for i in $DEPTS
    do
        if hash wget 2>/dev/null; then
            wget -N "http://bano.openstreetmap.fr/data/bano-$i.csv"
        else
            curl -RO -z bano-$i.csv "http://bano.openstreetmap.fr/data/bano-$i.csv"
        fi
    done
fi

if [ $PROCESS -eq 1 ];
then
    echo "Processing..."
    echo > "$BANODIR"/bano-$MAP.csv
    for i in $DEPTS
    do
        cat "$BANODIR"/bano-"$i".csv >> "$BANODIR"/bano-$MAP.csv
    done

    awk -f "$SCRIPTDIR"/bano2osm.awk "$BANODIR"/bano-$MAP.csv > "$BANODIR"/bano-$MAP.osm

    echo On low memory  machines use the --hash-memory=400-50-2 option
    # Below line is the original with the full france map
    #$BINDIR/osmconvert -v --hash-memory=400-50-2 $PBFDIR/$MAP-latest.osm.pbf "$BANODIR"/bano-$MAP.osm --out-pbf > $PBFDIR/$MAP-latest-with-bano.osm.pbf
    
    # lines below first convert the full france map to a address only map and then merges it with the bano map
    $BINDIR/osmconvert -v --drop-version --hash-memory=400-50-2 $PBFDIR/$MAP-latest.osm.pbf --out-o5m > $PBFDIR/$MAP-latest.o5m
    # Now create an osm file only containing addresses (and some garbage left)
    $BINDIR/osmfilter  --drop-version --parameter-file="$SCRIPTDIR"/address_only.txt --hash-memory=400-50-2 $PBFDIR/$MAP-latest.o5m -o=$PBFDIR/$MAP-latest-address.o5m
    # Now create an osm file containing the admin boundaries necessary for OsmAnd to create an address map
    $BINDIR/osmfilter --drop-version $PBFDIR/$MAP-latest.o5m --hash-memory=400-50-2 --keep="boundary=administrative" --out-o5m -o=$PBFDIR/$MAP-latest-boundaries.o5m
    # Now create the combined address map
    $BINDIR/osmconvert -v --hash-memory=400-50-2 $PBFDIR/$MAP-latest-boundaries.o5m $PBFDIR/$MAP-latest-address.o5m "$BANODIR"/bano-$MAP.osm --out-pbf > $PBFDIR/$MAP-latest-with-bano.osm.pbf

fi

