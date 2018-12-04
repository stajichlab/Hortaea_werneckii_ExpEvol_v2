#!/usr/bin/bash 

#SBATCH --nodes 1 --ntasks 16 --mem 24G --out logs/aln.%a.log --time 2:00:00 -p short

#This script takes a reference genome and a tab delimited sample list of: sample name\tsample_reads_1.fq\tsample_reads_2.fq.
# For each line defined by the number in an array job, this script will align set of reads to a reference genome using bwa mem.
#After, it uses picard to add read groups and mark duplicates. 

RGCENTER=UCR
RGPLATFORM=Illumina
CONFIG=config.txt
BWA=bwa
if [ -f $CONFIG ]; then
    source $CONFIG
fi

TEMPDIR=/scratch

module load bwa/0.7.17
module load picard
module load samtools/1.9
module unload java
module load java/8

CPU=1

hostname
mkdir -p $ALNFOLDER

if [ $SLURM_CPUS_ON_NODE ]; then
 CPU=$SLURM_CPUS_ON_NODE
fi
N=${SLURM_ARRAY_TASK_ID}

if [ ! $N ]; then
 N=$1
 if [ ! $N ]; then 
    echo "Need a number via slurm --array or cmdline"
    exit
 fi
fi

if [ ! $SAMPLESINFO ]; then
    echo "need to define \$SAMPLESINFO in $CONFIG file"
    exit
fi
GENOMEIDX=$GENOMEFOLDER/$GENOMENAME
echo "$GENOMEIDX"
IFS=,
#FCID,Lane,SampleID,SampleRef,Index,Description,Control,Recipe,Operator,SampleProject

tail -n +2 $SAMPLESINFO | sed -n ${N}p | while read FCID Lane SAMPLEID SAMPLE Index Description Control Recipe Operator SampleProject
do
    READ1=$FASTQFOLDER/${SAMPLEID}_${Index}_L00${Lane}_R1_001.fastq.gz 
    READ2=$FASTQFOLDER/${SAMPLEID}_${Index}_L00${Lane}_R2_001.fastq.gz
    PU=$Recipe
    SAMPLE=$SAMPLE.$REFNAME
    if [ -z $CTR ]; then
	    CTR=$RGCENTER
    fi
    echo "SAMPLE=$SAMPLE READ1=$READ1 READ2=$READ2 center=$CTR"
    if [ ! -f $ALNFOLDER/$SAMPLE.DD.bam ]  || [ ! -s $ALNFOLDER/$SAMPLE.DD.bam ]; then
        if [ ! -f $ALNFOLDER/$SAMPLE.sort.bam ]; then
            $BWA mem -M -t $CPU $GENOMEIDX $READ1 $READ2 | samtools sort -T /scratch/$SAMPLE --reference $GENOMEIDX.fasta -@ $CPU -o $ALNFOLDER/$SAMPLE.sort.bam -
        fi
	picard AddOrReplaceReadGroups RGID=$SAMPLE RGSM=$SAMPLE RGLB=$PU RGPL=$RGPLATFORM RGPU=$PU RGCN=$CTR I=$ALNFOLDER/$SAMPLE.sort.bam O=$ALNFOLDER/$SAMPLE.RG.bam \
		VALIDATION_STRINGENCY=SILENT

        picard MarkDuplicates I=$ALNFOLDER/$SAMPLE.RG.bam O=$ALNFOLDER/$SAMPLE.DD.bam \
            METRICS_FILE=$ALNFOLDER/$SAMPLE.dedup.metrics VALIDATION_STRINGENCY=SILENT CREATE_INDEX=true

	unlink $ALNFOLDER/$SAMPLE.RG.bam
    fi
done
