#!/bin/bash

set -eu

BANODIR=.
PBFDIR=..
BINDIR=.

if [ "$#" -ne 1 ];
then
	echo "Usage : $0 <region>"
	echo "where region can be france or any of those listed on http://download.geofabrik.de/europe/france.html"
	exit 1
fi

if [ ! -e $PBFDIR/$1-latest.osm.pbf ]
then
	echo "File not found : $PBFDIR/$1-latest.osm.pbf"
	exit 2
fi

DEPTS=$(grep $1 BANO-region-departements-mapping.txt | cut -f 2 | sed s/,/\ /g)

cd $BANODIR
for i in $DEPTS
do
       if hash wget 2>/dev/null; then
		wget -N http://bano.openstreetmap.fr/data/bano-$i.csv
	else
		curl -RO -z bano-$i.csv http://bano.openstreetmap.fr/data/bano-$i.csv
	fi
done

echo > bano-$1.csv
for i in $DEPTS
do
        cat bano-"$i".csv >> bano-$1.csv
done

awk -f bano2osm.awk bano-$1.csv > bano-$1.osm

$BINDIR/osmconvert $PBFDIR/$1-latest.osm.pbf bano-$1.osm --out-pbf > $PBFDIR/$1-latest-with-bano.osm.pbf

