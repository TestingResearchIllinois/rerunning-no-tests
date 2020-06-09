#!/bin/bash

tminfail=0
tmaxfail=0
tsum=0
ttsr=0

timinfail=0 
timaxfail=0
ttic=0

for f in $(tail -n +2 ../isoVtsoRate/all-test-info.csv | cut -d, -f1,4 | sort -u); do
    imaxpass=0;
    iminpass=5000;
    
    maxpass=0;
    minpass=5000;
    sum=0;
    
    c=0;
    s=$(echo $f | cut -d, -f1);
    m=$(echo $f | cut -d, -f2);

    ic=0;

    for g in $(grep "^$s," ../isoVtsoRate/all-test-info.csv | grep ,$m,); do
	c=$(( c + 1));
	pass=$(echo $g | cut -d, -f6);
	maxpass=$(( maxpass < pass ? pass : maxpass ));
	minpass=$(( minpass < pass ? minpass : pass ));
	sum=$(( sum + (4000 - pass) ));

	ipass=$(echo $g | cut -d, -f8);
	if [[ "$ipass" != "4000" ]] && [[ "$ipass" != "0" ]]; then
	    imaxpass=$(( imaxpass < ipass ? ipass : imaxpass ));
	    iminpass=$(( iminpass < ipass ? iminpass : ipass ));
	    ic=$(( ic + 1))
	fi
    done;
    iminfail=$(printf %.1f $(echo "((4000 - $imaxpass) / 4000) * 100" | bc -l));
    imaxfail=$(printf %.1f $(echo "((4000 - $iminpass) / 4000) * 100" | bc -l));

    minfail=$(printf %.1f $(echo "((4000 - $maxpass) / 4000) * 100" | bc -l));
    maxfail=$(printf %.1f $(echo "((4000 - $minpass) / 4000) * 100" | bc -l));
    sumfail=$(printf %.1f $(echo "($sum / 4000) * 100" | bc -l));

    map=$(grep "^$f," ../module-mapping-filtered.csv | cut -d, -f3);
    tv=$(grep "$map" ./tsr-rates.csv | cut -d, -f2);
    tsr=$(printf %.1f $(echo "$tv * 100" | bc -l));

    if (( $(echo "$sumfail > 100.0" | bc -l) )); then
	sumfail="100.0";
    fi;

    if [[ "$ic" == "0" ]]; then
	: # do nothing
    elif [[ "$ic" == "1" ]]; then
	timinfail=$(printf %.1f $(echo "$imaxfail + $timinfail" | bc -l));
	timaxfail=$(printf %.1f $(echo "$imaxfail + $timaxfail" | bc -l));
	ttic=$(( ttic + 1))
    else
	ttic=$(( ttic + 1))
	timinfail=$(printf %.1f $(echo "$iminfail + $timinfail" | bc -l));
	timaxfail=$(printf %.1f $(echo "$imaxfail + $timaxfail" | bc -l));
    fi

    tminfail=$(printf %.1f $(echo "$minfail + $tminfail" | bc -l));
    tmaxfail=$(printf %.1f $(echo "$maxfail + $tmaxfail" | bc -l));
    tsum=$(printf %.1f $(echo "$sumfail + $tsum" | bc -l));
    ttsr=$(printf %.1f $(echo "$ttsr + $tsr" | bc -l));

    if [[ "$iminfail" == "0.0" ]]; then
	iminfail='$<$0.1';
    fi;

    if [[ "$imaxfail" == "0.0" ]]; then
	imaxfail='$<$0.1';
    fi;

    if [[ "$tsr" == "0.0" ]]; then
	tsr='$<$0.1';
    fi;

    if [[ "$minfail" == "0.0" ]]; then
	minfail='$<$0.1';
    fi;
    
    if [[ "$c" == "1" ]] && [[ "$ic" == "0" ]]; then
	echo "$map & $tsr & = & = & = & n/a & n/a \\\\";
    elif [[ "$c" != "1" ]] && [[ "$ic" == "0" ]]; then
	echo "$map & $tsr & $minfail & $maxfail & $sumfail & n/a & n/a \\\\";
    elif [[ "$c" == "1" ]] && [[ "$ic" == "1" ]]; then
	echo "$map & $tsr & = & = & = & $imaxfail & = \\\\";
    elif [[ "$c" != "1" ]] && [[ "$ic" == "1" ]]; then
	echo "$map & $tsr & $minfail & $maxfail & $sumfail & $imaxfail & = \\\\";
    else
	echo "$map & $tsr & $minfail & $maxfail & $sumfail & $iminfail & $imaxfail \\\\";
    fi
done

aiminfail=$(printf %.1f $(echo "$timinfail / $ttic" | bc -l));
aimaxfail=$(printf %.1f $(echo "$timaxfail / $ttic" | bc -l));

aminfail=$(printf %.1f $(echo "$tminfail / 26" | bc -l));
amaxfail=$(printf %.1f $(echo "$tmaxfail / 26" | bc -l));
asum=$(printf %.1f $(echo "$tsum / 26" | bc -l));
atsr=$(printf %.1f $(echo "$ttsr / 26" | bc -l));

echo "\textbf{Total / Average} & \textbf{$atsr} & \textbf{$aminfail} & \textbf{$amaxfail} & \textbf{$asum} & \textbf{$aiminfail} & \textbf{$aimaxfail} \\\\"
