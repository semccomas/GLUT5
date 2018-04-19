##############################################
#### READ ME FIRST DUMMY!!!!!########################
#### THE $lipid is only for naming, you have to physically change the lipids in the insane.py part
### this also is not a perfect script, we have to change the group naming for genion and make_ndx 
#### (see ~line 66-70). You have to do a bit of manual work to see which groups you need but then just empty the directory and run
### this script again, it is really fast to do #####
##################################################

outdir=/data2/glut5_cg/POPC_POPE.90_10
refdir=/data2/glut5_cg
lipid=POPC_POPS
#refdir has all the forcefield info, all the mdp files, the original pdb file
cd $outdir 

echo '###############################'
echo '####### martinize.py ##########'
echo '################################'
### MAKE COARSE GRAINED MODEL
python $refdir/martinize.py -f $refdir/4YBQ_complete.pdb -o system.top -x 4YBQ_CG.pdb -n index.ndx -v -p Backbone\
 -pf 1000 -ff martini22 -elastic -ef 500 -el 0.5 -eu 0.9
#eu 0.9 nm = 9A - can switch off in .mdp or .top file with #define NO_RUBBER_BANDS
# output restraints on backbone, 1000. Should be enough for equilib otherwise we will add more here

### put protein in a box
gmx editconf -f 4YBQ_CG.pdb -o 4YBQ_CG.box.gro -d 1.5 -bt dodecahedron

mv system.top old_system.top #won't need this one
mv index.ndx old_index.ndx
echo '#################################'
echo '######### insane.py #############'
echo '##################################'
### INSANE.PY

#also need to neutralize protein, has total charge of -5
python $refdir/insane -f 4YBQ_CG.box.gro -o 4YBQ_CG.$lipid.gro -p system.top -pbc square -box 14,14,11 -l POPC:9 -l POPS:1 -center -sol W
#box size is 140A in x and y direction (protein is only about 8 but I want some space for the lipids to move around)
# the L and the U we will eventually change - asymmetry =-l DPPC:4 -l DIPC:3 -l CHOL:3. Don't need to specify u if not different from L


echo '#################################'
echo '###### editing system.top #######'
echo '##################################'
## EDIT SYSTEM.TOP
#include "martini.itp"
sed -i 's|#include "martini.itp"|#include "'$refdir'/martini_v2.2.itp"|' system.top   #replace the topology file - using | instead of / to escape '/' as a special char
sed -i '2i #define RUBBER_BANDS' system.top
sed -i '3i #include "'$refdir'/martini_v2.0_ions.itp"' system.top
sed -i '4i #include "'$refdir'/martini_v2.0_lipids_all_201506.itp"' system.top #for adding new line for lipids

#this adds bacmartini_v2.0_ions.itpk the protein itp file from martinize and rename Protein to Protein_X so it matches itp file
sed -i '5i #include "Protein_X.itp"' system.top 
sed -i 's/Protein    /Protein_X  /' system.top

gmx make_ndx -f 4YBQ_CG.$lipid.gro << EOF
q
EOF


echo '#################################'
echo '##### minimizing / gen ions #####'
echo '##################################'
### grompp just to make .tpr file for genion

gmx grompp -f $refdir/genion.mdp -o genion.tpr -p system.top -c 4YBQ_CG.$lipid.gro

gmx genion -s genion.tpr -o 4YBQ_CG.$lipid.neutral.gro -conc 0.15 -neutral -nname CL- -pname NA+ -p system.top -n index.ndx << EOF
15
EOF

sed -i 's|   CL|  CL-|' 4YBQ_CG.$lipid.neutral.gro
sed -i 's|   NA|  NA+|' 4YBQ_CG.$lipid.neutral.gro


#echo "CL-              5" >> system.top

gmx make_ndx -f 4YBQ_CG.$lipid.neutral.gro << EOF
15 | 18
name 24 SOL   
19 | 20
name 25 LIPID
q
EOF


#this we have added to the .mdp files, so groups are Protein, POPC, Solute
sed -i 's|POPC|LIPID|' $refdir/*.mdp

gmx grompp -f $refdir/minim.mdp -o minim.tpr -c 4YBQ_CG.$lipid.neutral.gro -p system.top -n index.ndx

gmx mdrun -deffnm minim -nt 3 -pin on

echo '#################################'
echo '###### equilibrating system #######'
echo '##################################'
### EQUILIBRATE STRUCTURE

gmx grompp -f $refdir/equil.1.mdp -o equil.1.tpr -c minim.gro -p system.top -n index.ndx
gmx mdrun -deffnm equil.1 -nt 3 -pin on

cnt=2
cntmax=6

while [ "$cnt" -le "$cntmax" ]
do
        pcnt=$((cnt-1))
        gmx grompp -f $refdir/equil.$cnt.mdp -o equil.$cnt.tpr -c equil.$pcnt.gro -p system.top -n index.ndx -maxwarn 1
        gmx mdrun -deffnm equil.$cnt -nt 3 -pin on
        cnt=$((cnt+1))
done




echo '#################################'
echo '######### done! #################'
echo '##################################'
echo 'To run production, do: gmx grompp, gmx mdrun'



