#!/bin/sh

rm -f etot.dat absfor.dat time.dat

echo '# total energy per atom in hartree' > etot.dat 
for s in si2*.out
do \
	grep -H TOTAL\ ENERGY  $s 			\
	| tail -1                 			\
	| awk '{printf "%-25s %15.10f\n", $1, $6/2.0}'	\
	>> etot.dat
done

for s in si16*.out
do \
	grep -H TOTAL\ ENERGY  $s 			\
	| tail -1                 			\
	| awk '{printf "%-25s %15.10f\n", $1, $6/16.0}'	\
	>> etot.dat
done

for s in si8*.out
do \
	grep -H TOTAL\ ENERGY  $s 			\
	| tail -1                 			\
	| awk '{printf "%-25s %15.10f\n", $1, $6/8.0}'	\
	>> etot.dat
done

for s in si64*.out
do \
	grep -H TOTAL\ ENERGY  $s 			\
	| tail -1                 			\
	| awk '{printf "%-25s %15.10f\n", $1, $6/64.0}'	\
	>> etot.dat
done

echo '# total squared force per atom' > absfor.dat
for s in si2*.out
do \
	printf "%-25s" ${s}: >> absfor.dat
	grep -A2 -- -FORCES $s | tr E e					\
	| tail -2                 					\
	| awk '{sum += $6*$6 + $7*$7 + $8*$8} END{ printf "%15.10f\n", sum/2.0}'	\
	>> absfor.dat
done

for s in si16*.out
do \
	printf "%-25s" ${s}: >> absfor.dat
	grep -A16 -- -FORCES $s | tr E e					\
	| tail -16                 					\
	| awk '{sum += $6*$6 + $7*$7 + $8*$8} END{ printf "%15.10f\n", sum/16.0}'	\
	>> absfor.dat
done

for s in si8*.out
do \
	printf "%-25s" ${s}: >> absfor.dat
	grep -A8 -- -FORCES $s | tr E e					\
	| tail -8                 					\
	| awk '{sum += $6*$6 + $7*$7 + $8*$8} END{ printf "%15.10f\n", sum/8.0}'	\
	>> absfor.dat
done

for s in si64*.out
do \
	printf "%-25s" ${s}: >> absfor.dat
	grep -A64 -- -FORCES $s | tr E e				\
	| tail -64                 					\
	| awk '{sum += $6*$6 + $7*$7 + $8*$8} END{ printf "%15.10f\n", sum/64.0}'	\
	>> absfor.dat
done


