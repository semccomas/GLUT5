start=21
stop=20
catout=1-20

working_dir=/data2/GLUT5/POPC_POPE.90_10/production/fc0_bb
intraj=PC_PE_fc0   #don't add xtc so we can add skip50 info


cd $working_dir
echo 0 > out.txt
while [ "$start" -le "$stop" ]
do
	gmx trjconv -f $intraj.$start.xtc -o $intraj.$start.skip50.xtc -s $intraj.$start.tpr -skip 50 -pbc whole < out.txt 

	start=$((start+1))

done

gmx trjcat -f `ls PC_PE_fc0!(*-*).skip50.xtc | sort -t . -k 2n` -cat -nooverwrite -o $intraj.$catout.all.xtc

## yeah the above won't work in the script, just  paste into terminal and it will go
echo $intraj.$catout.all.xtc
echo 'use this for the -o flag gmx trjcat'