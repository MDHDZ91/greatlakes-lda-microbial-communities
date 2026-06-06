# greatlakes-lda-microbial-communities
Analysis code for LDA-based topic modeling of Great Lakes microbial communities across size-fractionated 16S rRNA amplicon time series 2012-2019.

This repository is a work in progress and will be updated as the manuscript moves through peer review. For questions about the analysis, please contact María D. Hernández Limón at mdhernandez@uchicago.edu

## Overview
This repository contains the analysis code accompanying Hernández Limón et al. — "Topic modeling reveals thermally partitioned and taxonomically distinct microbial subcommunities across prokaryotes and phytoplankton in the Laurentian Great Lakes." Code is organized sequentially to reproduce all manuscript figures, from data preprocessing through LDA modeling, environmental driver analysis, and visualization.

This code is provided as a reproducible record of the analyses described in the manuscript, applied to four size-fractionated biological blocks (FL, PA, SSF, LSF). It is not a general-purpose package. Users wishing to apply this workflow to their own data should use the code as a reference and adapt inputs, parameters (including optimal k), and block structure accordingly

## Repository Structure
```
greatlakes-lda-microbial-communities/
├── README.md                        ← this file
├── LICENSE                          ← MIT license
├── .gitignore                       ← R-specific ignore rules
├── scripts/
│   ├── topic_analysis_pipeline.Rmd  ← full analysis pipeline and figure generation
│   └── perplexity/
│       ├── perplexity.R             ← perplexity analysis for LDA topic selection (K)
│       └── submit_perplexity.sh     ← SLURM submission script for HPC
└── figures/
    └── manuscript_figures.pdf       ← all manuscript figures
```

## Requirements
All analyses were conducted in R v4.5.3. For a full list of packages and versions see the Methods section of the accompanying manuscript. The core method relies on the alto package (v0.1.0) for LDA topic modeling. For a full list of packages and versions see the Methods section of the accompanying manuscript.

## General workflow
1. Clone the repo
2. Prepare your data
The pipeline expects a phyloseq object containing raw ASV counts, taxonomy, and sample metadata. The first function in my topic_analysis_pipeline.Rmd extracts these three components and structures them for downstream analysis. If you do not have a phyloseq object, these three tables can be provided separately.
3. Run LDA and validate number of topics (k)
Open scripts/topic_analysis_pipeline.Rmd and work through steps 1–3. If you are working with multiple datasets, the pipeline will need to be run once per dataset as shown in the manuscript code. LDA via alto ran nicely on my local machine for my datasets; larger datasets may benefit from HPC resources.To validate k, run the perplexity analysis in scripts/perplexity/ — I recommend running this on an HPC as it is computationally intensive. The script returns a .csv that feeds back into step 3.
5. Resume the main pipeline
Continue through steps 4–5 for GoMDE (fingerprint taxa), Limma and Random Forest + SHAP (environmental associations), and GCA (cross-block integration if working with multiple datasets).

## Citation
If you use this code or a verion of this pipeline please cite:
Hernández Limón MD, Donnat C, Bunbury F, Coleman ML. Topic modeling reveals thermally partitioned and taxonomically distinct microbial subcommunities across prokaryotes and phytoplankton in the Laurentian Great Lakes. bioRxiv 2026. DOI: [to be added upon posting]

## Data Availability
Sequences are deposited in NCBI under BioProject accession number PRJNA1259575 and will be made publicly available upon peer-reviewed publication of the companion manuscript.

## License
MIT
