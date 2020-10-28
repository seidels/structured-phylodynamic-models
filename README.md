# structured-phylodynamic-models
Code to reproduce the results of the paper "Quantitative comparison of pylodynamic models for structured populations"

## Step 1: Simulation

Simulate the trees for the
a) endemic scenario 
b) epidemic scenario

using the code within the *simulation directory*.

## Step 2: Parameter inference

Infer the migration rates and root location from the trees using the MBD and SC for (a) and (b), respectively, using the code within the *parameter_inference directory*.

## Step 3: Data analysis
Analyse the data using the code within the *analysis directory*


#### Note
In the manuscript, the multitype birth-death model is abbreviated with MBD. In the code you might find the abbreviations BD and BDrhoSamp, which refer to the same model. The structured coalescent was always abbreviated as SC.
