# /usr/bin/env bash

factorx='/vol3/home/johnsonr/problem-set-4/data'

gunzip $factorx/hg19.chr1.fq.gz

#build index of chromosome 1
bowtie2-build $factorx/hg19.chr1.fa $factorx/hg19.chr1

#align factor x to the genome
bowtie2 -x $factorx/hg19.chr1 -U $factorx/factorx.chr1.fq \
| samtools sort -o $factorx/factorx.sort.bam

#create bedgraph with factorx signal
bedtools genomecov -ibam $factorx/factorx.sort.bam -g $factorx/hg19.chrom.sizes -bg > $factorx/factorx.chr1.bg

#make bigwig binary format for ucsc upload
bedGraphToBigWig $factorx/factorx.chr1.bg $factorx/hg19.chrom.sizes factorx.bw

#create gh-pages git branch for ucsc upload
git branch gh-pages
git push origin gh-pages

#call peaks
macs2 callpeak -t factorx.sort.bam --nomodel -n factorx

# randomly select 1000 for motifs
shuf factorx_peaks.narrowPeak | head -n 1000 > factorx_rand1000.bed

#generate motifs from peak calls
bedtools getfasta -fi hg19.chr1.fa -bed factorx_rand1000.bed -fo factorx_rand.fa

#derive motifs
meme factorx_rand.fa -nmotifs 1 -maxw 20 -minw 8 -dna -maxsize 1000000

#get motif matrix for input into tomtom to search for motif
meme-get-motif -id 1 < meme_out/meme.txt

