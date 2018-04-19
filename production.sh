## NOTE!!!!!!!
# TO DO BEFORE YOU RUN THIS:
# 1- change cnts, outdir, refdir, simcodes
# 2-  copy index.ndx, system.top, and Protein_X.itp to this dir. 
# 3- change system.top in this dir to be #include $refdir/
# 4- be sure that production.mdp is what you want it to be!!
## DID YOU DO ALL OF THIS????????????????? DONT WASTE TIME CAUSE YOURE LAZY

########################
#USER DEFINED VARIABLES#
#######################

cnt=10
cntmax=50

simcode=PC_PE_fc0  #POPC:POPE 90:10

outdir=/data2/GLUT5/POPC_POPE.90_10/fc0_bb
refdir=/data2/GLUT5

cores_to_use=5

####################
# DO GROMACS MAGIC #
####################
cd $outdir

while [ "$cnt" -le "$cntmax" ]
do
        pcnt=$((cnt-1))
        if [ "$cnt" -eq 1 ]
        then
                gmx grompp -f $refdir/production.mdp -o $simcode.$cnt.tpr -c equil.6.gro -n index.ndx -p system.top -maxwarn 2
                gmx mdrun -deffnm $simcode.$cnt -s $simcode.$cnt.tpr -cpi $simcode.$cnt.cpt -nt $cores_to_use -pin on

        else
                gmx grompp -f $refdir/production.mdp -o $simcode.$cnt.tpr -c $simcode.$pcnt.gro -n index.ndx -p system.top -maxwarn 2
                gmx mdrun -deffnm $simcode.$cnt -s $simcode.$cnt.tpr -cpi $simcode.$cnt.cpt -nt $cores_to_use -pin on 
        fi

        cnt=$((cnt+1))
done


