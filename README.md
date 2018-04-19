This contains all information we need to run gromacs. The mdp files should stay in here so we don't have to copy them over to new trajectories, same with the .itp files

Also the scripts we need to run stuff are in here, sometimes I put them in the same dir as the .xtc files but these are the most updated working version of the scripts

Also here we have martinize and insane

Images we can find here

Volmaps are still in /data/residue_analysis/GLUT5

We have the OG pdb in here too, this has only one of the chains, the Fab removed, and is technically a homology model because there was a coil missing from TM1 to TM2


SOme of the .mdp files are for the system_setup.sh script
Some are for equilibration, and production.mdp is for production. The restraints in equilibration are as follows:

equil.1.mdp:define                   = -DFLEXIBLE  ; flexible is to select harmonic bonds for minimization
equil.2.mdp:define                   = -DPOSRES -DPOSRES_FC=1000 -DBILAYER_LIPIDHEAD_FC=200
equil.3.mdp:define                   = -DPOSRES -DPOSRES_FC=500 -DBILAYER_LIPIDHEAD_FC=100
equil.4.mdp:define                   = -DPOSRES -DPOSRES_FC=250 -DBILAYER_LIPIDHEAD_FC=50
equil.5.mdp:define                   = -DPOSRES -DPOSRES_FC=100 -DBILAYER_LIPIDHEAD_FC=20
equil.6.mdp:define                   = -DPOSRES -DPOSRES_FC=50 -DBILAYER_LIPIDHEAD_FC=10

production.mdp:;define               = -DPOSRES -DPOSRES_FC=10
you'll notice that this is commented out, we have an elastic network so I DONT THINK that we need FC=10 on the protein but I could be wrong
