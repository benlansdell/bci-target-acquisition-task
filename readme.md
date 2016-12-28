# Analysis of dual control BCI target pursuit task

Ben Lansdell, Ivana Milovanovic. 2016

MATLAB code for studying multi-electrode array recording data from monkey as performs manual, brain control and dual control target pursuit task. Data from [Moritz lab](http://depts.washington.edu/moritlab/), experiment setup by Charlie Matlack. 

### Dependencies:
* Makes use of functions in the stats toolbox.

Overall, the bulk of the code is structured as follows:

### In preprocess:

preprocess\_\* functions generate a structure for use by functions in ./models

* Functions for importing data from .nev and .nsx files. 
* Functions for importing trial data from Labview (.mat) files. 
* Functions for smoothing torque data, and converting spike times to binned spikes
* generate_glm_data.m for simulating a GLM given input data and filters

### In models:

Functions to take a preprocess structure output from ./preprocess, and generate a structure with data in appropriate format for fitting a GLM/linear model/etc to.

If the GLM has the form: $E(y) = g(X\beta)$ where $X$ is a data matrix and $\beta$ is a vector of filter coefficients, this directory contains functions for taking raw data and preparing data matrix to be input into a GLM, along with output vector y.

### In fitting: 

Functions to perform MLE fit of GLM model

### In eval:

Functions to interpret results of MLE fitting

* Functions to predict spike trains given stimulus and a fit GLM
* Functions to plot filters of GLM
* Granger causality connectivity
* Other plotting functions

### In scripts:
* Scripts that generate plots used in paper

### In functions:

Various support functions

* Functions to import blackrock files
* Functions to compute correlations, etc
* Functions to save plots as .eps
* Various other things

## In sql:

The size of the dataset and number of analyses performed necessitated managing fits and results in a SQL database. Here are functions to add fits and other analyses to a SQL database. Please contact us directly if you'd like to access our database containing our stored analyses and results, or would like to setup something similar yourself. 

## Ok ok, how to use:

If MATLAB is started in this directory then startup.m will automatically add the above directories to the path. It will try to add the Chronux functions by adding ~/matlab/chronux to the path, and will try to add the .nev and .ns3 files to the path by looking in ./matlab/blackrock, but these are not necessary.

In addition to code to perform analysis of GLM fits, our paper uses a number of other tools to analyze the data. This include GPFA and the transfer entropy toolbox. 


See ./accessing_data.txt for information on the format of matlab, labview and BlackRock files
