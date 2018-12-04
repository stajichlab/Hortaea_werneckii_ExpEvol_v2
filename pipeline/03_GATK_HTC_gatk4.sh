#!/bin/sh
#SBATCH --nodes=1
#SBATCH --ntasks=16
#SBATCH  --mem 32gb
#SBATCH  --time=48:00:00
#SBATCH --job-name HTC
#SBATCH --output=logs/HTC.%A_%a.out

module load java/8
module load gatk/4
module load picard
CONFIG=config.txt

if [ -f $CONFIG ]; then
    source $CONFIG
fi

hostname

MEM=16g
GENOMEIDX=$GENOMEFOLDER/$GENOMENAME

CPU=$SLURM_CPUS_ON_NODE

if [ ! $CPU ]; then 
 CPU=1
fi

N=${SLURM_ARRAY_TASK_ID}

if [ -z $N ]; then
 N=$1
 if [ ! $LINE ]; then
	 echo "Need a number via slurm --array or cmdline"
 	exit
 fi
fi

mkdir -p $VARIANTFOLDER
IFS=,
IFS=,
#FCID,Lane,SampleID,SampleRef,Index,Description,Control,Recipe,Operator,SampleProject

tail -n +2 $SAMPLESINFO | sed -n ${N}p | while read FCID Lane SAMPLEID SAMPLE Index Description Control Recipe Operator SampleProject
do
    	SAMPLE=$SAMPLE.$REFNAME
	IN=$ALNFOLDER/$SAMPLE.realign.bam
	if [[ $TYPE == "Pool" ]]; then
		echo "Skipping pooled sample"
		exit
	fi
# can setup different options here to specify whether we are using GATK4 or GATK3
#if [[ $GATK == "3" ]]; then
#elif [[ $GATK == "4" ]]; then
#else
#fi
	if [ ! -f $VARIANTFOLDER/$SAMPLE.g.vcf ]; then
		gatk --java-options -Xmx${MEM} HaplotypeCaller \
		  -ERC GVCF \
		  -ploidy 1 \
		  -I $IN -R $GENOMEIDX.fasta \
		  -O $VARIANTFOLDER/$SAMPLE.g.vcf \
		  --native-pair-hmm-threads $CPU
	fi
done
