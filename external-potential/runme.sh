#!/bin/sh

# tested with cpmd v3.8.4
# tested with cpmd2cube v0.1.3(?)
# tested with vmd v1.8.2

./cpmd.x h2o-dens-nopot.in > h2o-dens-nopot.out
./cpmd2cube.x -halfmesh -rho -o h2o-dens-nopot DENSITY

./mkextpot <<EOF
15.0 15.0 15.0
0.0 0.0 -7.5
108 108 108
EOF

./cpmd.x h2o-dens-extpot.in > h2o-dens-extpot.out
./cpmd2cube.x -halfmesh -rho -o h2o-dens-extpot DENSITY

cubman <<EOF
sub
h2o-dens-nopot.cube
yes
h2o-dens-extpot.cube
yes
h2o-dens-diff.cube
yes
EOF

echo "now run 'vmd -e h2o-dens-diff.vmd' to view the result"
