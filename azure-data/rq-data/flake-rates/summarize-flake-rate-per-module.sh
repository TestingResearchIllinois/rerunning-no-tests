#!/bin/bash

total_tso_detected=0; total_iso_detected=0; total_method_count=0; total_class_count=0; total_test_orders=0;

for f in $(cat ../module-info-filtered.csv ); do
    proj=$(echo $f | cut -d, -f1 );
    slug=$(echo $proj | cut -d'/' -f4-);
    mod=$(echo $f | cut -d, -f4);
    test=$(echo $f | cut -d, -f3);

    method_count=$(echo $f | cut -d, -f5);
    tso_detected=$(grep $proj tso-flake-rate.csv | grep ,$mod, | wc -l);
#    iso_detected=$(grep $proj iso-flake-rate.csv | grep ,$mod, | wc -l);

    # order_file=$( find per-module-order/ -name "*${test}-*" );
    # order_count=$(cat $order_file | wc -l);
    # class_count=$(head -1 $order_file | cut -d, -f2);

    if [[ "$((tso_detected+iso_detected))" != "0" ]]; then
	echo "\\Use{${slug}=${mod}_name} & ${slug} & ${method_count} & $tso_detected \\\\";
	total_tso_detected=$((total_tso_detected+tso_detected));
#	total_iso_detected=$((total_iso_detected+iso_detected));
	total_method_count=$((total_method_count+method_count));
	# total_class_count=$((total_class_count+class_count));
	# total_test_orders=$((total_test_orders+order_count));
    fi
done ;

echo "\hline \\multicolumn{2}{|l||}{\textbf{Total}} & \\textbf{${total_method_count}} & \\textbf{${total_tso_detected}} \\\\"
