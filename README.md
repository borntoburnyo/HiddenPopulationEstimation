# HiddenPopulationEstimation

In brief, this is a consulting project helping our client estimating hidden population size in Laos' forest-based area.

In detail, this is part of the project of Malaria Elimination Initiative ([MEI](http://www.shrinkingthemalariamap.org/)) of UCSF (University of San Francisco). As malaria is a deadly disease propagated by infected mosquito, which is highly forest-based insect. Laos has over 65% forest coverage, as a comparison the average forest coverage worldwide is 31%. To optimize budget and allocate limited resources to help eliminating malaria in Laos, the total population size is needed before any action (this information is not available yet due to the special nature of forest-based area). So the key point is to estimate the population size in forest-based area in Laos.

Capture-recapture method is used to get samples, example sample looks like:   

|Num of being captured|Count|
|---------------------|-----|
|1|20|
|2|12|
|3|9|
|..|..|

The number of people that never being captured is unknown, this is actually what we want to estimated. Expectation-Maximization algorithm is used to get estimate of such truncated data. Please refers to folder EMs.

To evaluate the goodness of point estimate and confidence interval, a simulation study is performed. Based on pilot survey,
people in the forest roughly fall into two clusters, frequent and rare users. First, create a grid with two parameters, 
population size ratio of two clusters and probability ration of being capture of two clusters. Then generate certain amount of
labeled captures from population with known size. Fit algorithms to the data, obtain all estimates. Lastly, draw a phase 
diagram to visualize the result. 
