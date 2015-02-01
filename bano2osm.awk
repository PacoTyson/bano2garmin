BEGIN {
    FS=",";
    OFS = "\n";
        print "<?xml version='1.0' encoding='UTF-8'?>\n<osm version='0.6' generator='bano2osm.awk'>";
	print "<!-- File generated from " FILENAME " -->"
}
match ($6, /C\+O|OD/) {
	gsub(/&/, "\\&amp;", $3)
	gsub(/'/, "\\&apos;", $3)
	gsub(/"/, "\\&quot;", $3)
        print "  <node id='" (-20000000+NR) "' lat='" $7 "' lon='" $8 "'>"
        print "    <tag k='addr:housenumber' v='" $2 "' />"
        print "    <tag k='addr:street' v='" $3 "' />"
        print "  </node>"
}
END {print "</osm>"}
