#!/bin/bash

set -eu

BANODIR=.
PBFDIR=..
BINDIR=.

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


DEPTS=$(grep $MAP BANO-mapping-region-departements.txt | cut -f 2 | sed s/,/\ /g)

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
    echo > bano-$MAP.csv
    for i in $DEPTS
    do
        cat "$BANODIR"/bano-"$i".csv >> bano-$MAP.csv
    done

    awk -f bano2osm.awk bano-$MAP.csv > bano-$MAP.osm

    $BINDIR/osmconvert $PBFDIR/$MAP-latest.osm.pbf bano-$MAP.osm --out-pbf > $PBFDIR/$MAP-latest-with-bano.osm.pbf
fi

