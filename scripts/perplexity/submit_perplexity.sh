#!/bin/bash
#SBATCH --job-name=perplexity
#SBATCH --output=per_mdh_%j.out
#SBATCH --error=per_mdh_%j.err
#SBATCH --time=06:00:00
#SBATCH --account=pi-mlcoleman
#SBATCH --partition=bigmem
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=14
#SBATCH --mem=64G
#SBATCH --mail-user=mdhernandez@uchicago.edu


### change the time after you are done troubleshooting 
#make sure conda is OFF or glm will not load correctly
eval "$(conda shell.bash hook)"

#pwd
conda deactivate #the automatic conda activation of base

##prepare your session
module load R/4.4.1
module load gsl
#module load gcc this will not match the R version you want to install your own
conda activate renv

# Define input variables
#FL, PA, SSF, LSF
size_fraction=$1  

export R_LIBS_USER="/scratch/midway3/mdhernandez/renv_topics/rlibs"

./perplexity.R $size_fraction 

conda deactivate


