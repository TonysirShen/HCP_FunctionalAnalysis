# Code Repository for the manuscript ""Cortical microcircuits regulate energy barriers governing behavioral state transitions"

## Overview
This repository contains analysis code for the M2 project.  
The codebase is organized into two major parts:

1. **Preprocessing modules** (`Preprocess/`)
2. **Figure-specific analysis modules** (`Figure 1`, `Figure 2`, `Figure 4`, etc.)

Several figure folders are further divided into submodules based on analysis type.

## Repository Structure

### 1. Preprocessing (`Preprocess/`)
- **`basic_analysis/`**  
  Basic signal analysis notebooks and generated intermediate CSV files.Input samples are provided
- **`DBscorer/`**  
  DBscorer-related resources, including executables, scripts, manuals, and media assets.
- **`mininan/`**  
  A standalone Python project for calcium imaging preprocessing/analysis, including:
  - source code (`minian/`)
  - documentation (`docs/`)
  - dependency specs (`requirements/`, `environment.yml`)
  - tests

### 2. Figure Modules
Each figure folder contains code and data used to reproduce specific figure panels.Some folder provide README.txt file for furthur explaination

- **`Figure 1/`**
  - `cFOS heatmap/`
  - `fMRI/`
  - `PCA+KNN/`

- **`Figure 2/`**
  - `event analysis/`
  - `RNN&RF prediction/`
  - `rSLDS_model/`

- **`Figure 4/`**
  - `Best time lag/`
  - `Correlation network/`
  - `RNN_interaction_modeling/`

- **`Figure 5/`**, **`Figure 6 & S12/`**, **`Figure S3/`**, **`Figure S4/`**, **`Figure S8/`**  
  Figure-specific scripts/notebooks and reference notes.

- **other figures**  
  Analysis is done with the code already provided.

## Suggested Workflow
1. Run preprocessing pipelines under `Preprocess/` (as needed by your dataset).
2. Open and execute notebooks/scripts in the relevant `Figure *` folder to reproduce results.
3. Check figure submodules for specific methods (e.g., event analysis, correlation network, RNN modeling).

## Notes
- This repository mixes executable code, intermediate data, and tool assets.
- Some folders (e.g., `DBscorer/`, `mininan/`) include third-party or standalone components with their own usage instructions.
- For reproducibility, use environment/configuration files where provided (especially under `Preprocess/mininan/`).

## Citation
If you use this repository in academic work, please cite the associated manuscript/project documentation.(TODO:provide link)
