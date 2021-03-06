#### this passes all fastq files to the following programs
import os
import yaml

file_list = []
### location assumes that data is in relabeled_reads/ibv/ folder
for entry in os.scandir("raw_reads/"):
    if entry.is_file():
        file_list.append(entry.name)
#### this tells where data is that will be used for dictionary
config_dict = {"samples":{i.split(".")[0]:"raw_reads/"+i for i in file_list}}

with open("config_bbtools.yaml","w") as handle:
    yaml.dump(config_dict,handle)

##### rule all is a general rule that says this is the results we are lookin for in the end.
##### Need to think back to front
configfile: "config_bbtools.yaml"

print("Starting trimming with bbnorm workflow")

rule all:
    input:
        expand("bbnorm/{sample}_bbduk_bbnorm.fastq", sample = config["samples"])

rule bbduk:
    input:
        lambda wildcards: config["samples"][wildcards.sample]
    output:
        trimmed="bbduk/{sample}_bbduk.fastq",
    shell:
        "bbduk.sh in={input} out={output} qtrim=rl trimq=20 maq=10 minlen=50"
        #### trimming right and left to quality of 20, minimum length of 50 bp and discard reads with quality below 10

rule bbnorm:
    input:
        "bbduk/{sample}_bbduk.fastq"
    output:
        "bbnorm/{sample}_bbduk_bbnorm.fastq"
    shell:
        "bbnorm.sh in={input} out={output} target=100 min=5"
