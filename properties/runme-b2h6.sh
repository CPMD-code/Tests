#!/bin/sh 
#PBS -l walltime=2:00:00
#

if [ "$PBS_ENVIRONMENT" = "PBS_BATCH" ]
then
  cd $PBS_O_WORKDIR
fi

# for this script to work, you need to have 
# cpmd.x and cpmd2cube.x executables in the current working directory
# and vmd version 1.8.2 in your searchpath
cdx=0
c2c=0
vmd=0

test -e ./cpmd.x      && cdx=1
test -e ./cpmd2cube.x && c2c=1
hash vmd 2> /dev/null && vmd=1

test $cdx -eq 1 || echo WARNING: cpmd.x is NOT available
test $c2c -eq 1 || echo WARNING: cpmd2cube is NOT available
test $vmd -eq 1 || echo WARNING: vmd is NOT available

# no point in continuing without cpmd.x
test $cdx -eq 1 || exit 666

# redirect stdout and stderr to a file
exec 1> runme-b2h6.log
exec 2>&1

# turn on verbose shell execution
set -vx

# first clean up the mess from the last run.
rm -f RESTART* DENSITY* EL* LATEST GEOMETRY* GSHELL *.tga\
    *.cube *.pdb IONS+CENTER* WANNIER* OVERLAP WFNCOEF

# optimize the wf and get a first set of 'DENSITY' format files...
./cpmd.x b2h6-wf.inp . > b2h6-wf.out.`arch`
if [ $c2c ]
then
  ./cpmd2cube.x -o b2h6-elf   -rho -halfmesh  ELF 
  ./cpmd2cube.x -o b2h6-dens  -rho -halfmesh  DENSITY
  ./cpmd2cube.x -o b2h6-elpot -rho -halfmesh  ELPOT
fi

# and calculate lots of properties
./cpmd.x b2h6-prop.inp . > b2h6-prop.out.`arch`
if [ $c2c ]
then
  ./cpmd2cube.x -o b2h6-local- -psi -halfmesh WANNIER_1.[0-9]*
fi
mv RHO_TOT.cube b2h6-rho.cube
mv IONS+CENTERS.xyz b2h6-wc.xyz

# diagonalize the remaining KS orbitals...
./cpmd.x b2h6-ks.inp . > b2h6-ks.out.`arch`

# now get some KS orbitals
./cpmd.x b2h6-ksorbs.inp . > b2h6-ksorbs.out.`arch`

# rename the next batch of outputs.
for f in 01 02 03 04 05 06 07 08 09 10 11 12 13 14
do
  test -f PSI.0$f.cube && mv PSI.0$f.cube b2h6-orb-$f.cube
done

# use vmd to generate a picture gallery.
if [ $vmd ]
then
  vmd -dispdev none -size 600 400 -e b2h6-wannier.vmd
  if [ $c2c ]
  then
    vmd -dispdev none -size 600 400 -e b2h6-dens.vmd
    vmd -dispdev none -size 600 400 -e b2h6-elpot.vmd
    vmd -dispdev none -size 600 400 -e b2h6-elf.vmd
    vmd -dispdev none -size 600 400 -e b2h6-local-orbs.vmd
  fi
  vmd -dispdev none -size 600 400 -e b2h6-rho.vmd
  vmd -dispdev none -size 600 400 -e b2h6-ksorb-1.vmd
  vmd -dispdev none -size 600 400 -e b2h6-ksorb-6.vmd
  vmd -dispdev none -size 600 400 -e b2h6-ksorb-7.vmd
  vmd -dispdev none -size 600 400 -e b2h6-ksorb-8.vmd
fi

# clean up the mess from this run.
rm -f RESTART* DENSITY* EL* LATEST GEOMETRY* GSHELL \
    *.pdb WANNIER* OVERLAP WFNCOEF
exit 0
