# HiddenPopulationEstimation
Project of ([MEI](http://www.shrinkingthemalariamap.org/)) Malaria Elimination Initiative of UCSF (University of San Francisco). Key point is to estimate forest based
population size of Laos. As malaria is propagated by infected mosquito, and mosquito is forest-based insect. Laos has over 65%
forest coverage, as a comparison the average forest coverage worldwide is 31%. So to better allocate resources to eliminate
malaria in Laos, which is most severely affected country in south east Asia. Estimate the whole population of Laos' forest
based ares becomes important for the project to move on (Laos government could not provid this information).

Capture-recapture method is used to get samples, example sample looks like:   

|Num of being captured|Count|
|---------------------|-----|
|1|20|
|2|12|
|3|9|
|..|..|

The number of people that never being captured is unknown, this is also what we want to estimated. Expectation-Maximization 
algorithm is used to get MLE of such truncated data. Please refers to folder EMs.

To evaluate the goodness of point estimate and confidence interval, a simulation study is performed. Based on pilot survey,
people in the forest roughly fall into two clusters, frequent and rare users. First, create a grid with two parameters, 
population size ratio of two clusters and probability ration of being capture of two clusters. Then generate certain amount of
labeled captures from population with known size. Fit algorithms to the data, obtain all estimates. Lastly, draw a phase 
diagrm to visualize the result. 
