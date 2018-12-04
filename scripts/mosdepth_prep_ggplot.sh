#!/bin/bash
# 5000 20000
for WINDOW in 20000 10000 5000;
do
 for file in $(ls coverage/mosdepth/*.${WINDOW}bp.regions.bed.gz | grep -v ATCC | grep -v ctl[12])
 do
     # b=$(basename $file .${WINDOW}bp.regions.bed.gz | perl -p -e 's/(ctl([12]))\.AL1B/A$1.L1B-$2/; s/(\S+)\.(\S+)/$2/')
     b=$(basename $file .${WINDOW}bp.regions.bed.gz)

     GROUP=$(echo $b | perl -p -e 'if (/(\d+Hw)/) { $_ = "$1\n" }')
#my $new = $lookup{$in}->[-1]; 
#$_ = $new."\n"')
 # echo "$GROUP $b"
 mean=$(zcat $file | awk '{total += $4} END { print total/NR}') 
 zcat $file | awk 'BEGIN{OFS="\t"} {print $1,$2,$3,$4/'$mean','\"$GROUP\"','\"$b\"'}' 
 done  > coverage/mosdepth.${WINDOW}bp.gg.tab
 pigz -f coverage/mosdepth.${WINDOW}bp.gg.tab
done


