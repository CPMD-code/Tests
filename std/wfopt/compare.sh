#!/bin/sh

rm -f etot.dat absfor.dat time.dat

echo '# total energy in hartree' > etot.dat 
for s in *.out
do \
	grep -H TOTAL\ ENERGY  $s 		\
	| tail -1                 		\
	| awk '{printf "%-25s %15s\n", $1, $6}'	\
	>> etot.dat
done

echo '# wall time in seconds' > time.dat 
for s in *.out
do \
	grep -H  ELAPSED\ TIME\ :  $s 		\
	| awk '{printf "%-25s %15d\n", $1, ($5*60.0 + $7)*60.0 + $9;}'	\
	>> time.dat
done

echo '# total squared force' > absfor.dat
for s in *.out
do \
	printf "%-25s" ${s}: >> absfor.dat
	grep -A9 -- -FORCES $s | tr E e		\
	| tail -9                 		\
	| awk '{sum += $6*$6 + $7*$7 + $8*$8} END{ print sum}'	\
	>> absfor.dat
done


