# structured-phylodynamic-models
Code to reproduce the results of the paper "Quantitative comparison of pylodynamic models for structured populations"

In the manuscript, the multitype birth death model is abbreviated as MBD. In the code, you might find BD or BDrhoSamp which refers to the same model. The structured coalescent is always abbreviated as SC.

Step 1: Simulate the trees for the
a) endemic scenario 
b) epidemic scenario

using the code within the *simulation directory*.

Step 2: Infer the paramaters (in manuscript migration rate and root location) from the trees using the MBD and SC for (a) and (b) respectively using the code within the *parameter_inference directory*.

Step 3: Analyse the data using the code within the *analysis directory*
