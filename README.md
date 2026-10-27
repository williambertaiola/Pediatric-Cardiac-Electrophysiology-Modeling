# Pediatric Cardiac Electrophysiology Modeling

## Project Overview

This project focuses on the computational analysis of pediatric ventricular electrophysiology across different age groups.

The study investigates how variations in ionic conductances influence ventricular action potentials and intracellular calcium dynamics using MATLAB simulations based on the **O'Hara–Rudy cardiac electrophysiology model**.

Five pediatric populations were considered to evaluate age-dependent differences in electrophysiological behavior.

## Objectives

The main objectives of this project are:

* Analyze ventricular electrophysiological characteristics across different pediatric age groups.
* Investigate the effects of ionic conductance variations on cardiac electrical activity.
* Evaluate changes in action potential morphology and calcium dynamics.
* Perform sensitivity analysis on selected ionic conductances.
* Compare electrophysiological biomarkers across pediatric populations.

## Methodology

The computational analysis was performed using **MATLAB** and adapted versions of the **O'Hara–Rudy ventricular electrophysiology model**.

### Pediatric Age Groups

Five pediatric age groups were investigated:

1. **Neonates**
2. **Infants**
3. **Preschool children**
4. **School-age children**
5. **Adolescents**

### Sensitivity Analysis

A sensitivity analysis was conducted on **12 ionic conductances**, varying each parameter by:

* **-30%**
* **-15%**
* **Baseline**
* **+15%**
* **+30%**

Simulations were performed at two stimulation frequencies:

* **0.5 Hz**
* **1 Hz**

A total of **600 simulation configurations** were considered.

## Electrophysiological Biomarkers

The following biomarkers were analyzed:

* **APD90:** Action potential duration at 90% repolarization.
* **CaTD90:** Calcium transient duration at 90% recovery.
* **Action potential triangulation:** Measurement of action potential morphology.
* **ICaL peak:** Peak L-type calcium current.

These biomarkers were used to evaluate the sensitivity of ventricular electrophysiological behavior to ionic conductance variations.

## Technologies and Tools

* **MATLAB**
* Computational Modeling
* Cardiac Electrophysiology
* O'Hara–Rudy Model
* Sensitivity Analysis
* Biomedical Data Analysis
* Scientific Visualization

## Repository Structure

The repository is organized into the following sections:

* **1_Neonato:** MATLAB simulations for neonatal ventricular models.
* **2_Lactante:** MATLAB simulations for infant ventricular models.
* **3_Nino_preescolar:** MATLAB simulations for preschool-age ventricular models.
* **4_Edad_escolar:** MATLAB simulations for school-age ventricular models.
* **5_Adolescente:** MATLAB simulations for adolescent ventricular models.
* **All:** Comparative analyses and results across pediatric populations.
* **report:** Academic report describing the methodology and analysis.

## Project Outcomes

The project provides a computational approach to investigating age-dependent variability in pediatric ventricular electrophysiology.

The sensitivity analysis allows the evaluation of how changes in ionic conductances affect electrophysiological biomarkers and supports comparisons between different pediatric populations.

## Academic Context

This project was developed as part of an academic biomedical engineering activity at the **Universitat Politècnica de València (UPV)**.

The repository documents the MATLAB simulations, computational analyses, and scientific methodology used in the study.
