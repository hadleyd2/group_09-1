# Group 09
Repository for Kristina Wright and Daniel Hadley group project for [STAT 547M](https://stat545.stat.ubc.ca/)

## 1. About This Repository :information_source:
> This repository houses Group 09's project for STAT 547M taken in Term 2 of the 2019-2020 academic here.
>
> Our project uses an Airbnb dataset to try and find significant factors to explain the listing prices (per night) in Barcelona, Spain.
>
> The final report is created by meeting milestones which are linked below.

## 2. Navigating the Repository :file_folder:
> As milestones are met, files are placed into the appropriate subfolders. 

1. The [data](https://github.com/hadleyd2/group_09-1/tree/master/data) folder contains all datasets used throughout the project.
1. The [docs](https://github.com/hadleyd2/group_09-1/tree/master/docs) folder contains all `*.Rmd` files used to create reports.
1. The [images](https://github.com/hadleyd2/group_09-1/tree/master/images) folder saves all images produced for the group project.
1. The [scripts](https://github.com/hadleyd2/group_09-1/tree/master/scripts) folder saves all `R` scripts (`*.r`) that are called when rendering the project.
1. The [tests](https://github.com/hadleyd2/group_09-1/tree/master/tests) folder contains all tests carried out when producing the analysis.

| Milestone | Due Date :date: | Report
| :--: | ---- | :--------------: |
| [01](https://stat545.stat.ubc.ca/evaluation/milestone_01/milestone_01/) | February 29, 2020 | [milestone01](https://hadleyd2.github.io/group_09-1/docs/milestone01/milestone01.html) |
| [02](https://stat545.stat.ubc.ca/evaluation/milestone_02/milestone_02/) | March 7, 2020 | [milestone02](https://hadleyd2.github.io/group_09-1/docs/milestone02/milestone02.html) |
| [03](https://stat545.stat.ubc.ca/evaluation/milestone_03/milestone_03/) | March 14, 2020 | [html](https://hadleyd2.github.io/group_09-1/docs/final_report.html) and [pdf](https://hadleyd2.github.io/group_09-1/docs/final_report.pdf) |

## 3. Usage :computer:

1. Clone this repo.

1. Ensure the following `R` packages are installed:

    - `tidyverse`
    - `here`
    - `docopt`
    - `knitr`
    - `DT`
    - `gridExtra`
    - `corrplot`
    - `glue`
    - `scales`
    - `broom`
  
1. Option 1: Run the following scripts (in order) in terminal from the main repo directory with the specified arguments:

    a) **Load data**
    `Rscript scripts/load.R --data_url=https://raw.githubusercontent.com/STAT547-UBC-2019-20/data_sets/master/listings-Barcelona.csv`
  
    b) **Clean data**
    `Rscript scripts/process.R --path_raw=data/raw_listings.csv --path_clean=data/clean_listings.csv`
  
    c) **Exploratory data analysis**
    `Rscript scripts/EDA.R --path_clean=data/clean_listings.csv --path_image=images/`
    
    d) **Linear Regression**
    `Rscript scripts/lm.R --path_data=data/clean_listings.csv`
  
    e) **Knit final report**
    `Rscript scripts/knit.R --final_report="docs/final_report.Rmd"`

1. Option 2: Run make in terminal from the main repo directory to run all individual scripts above:

    a) **Dependency**
    Ensure `make` is installed
    
    b) **Run all scripts and reproduce analysis**
    `make all`
    
    c) **Delete all output from scripts**
    `make clean`
    
## 4. Dashboard Proposal

### Dashboard Description

This app will have features for data exploration and data analysis. Data exploration presents a density of Airbnb listing prices for Barcelona, Spain and allows the user to select a categorical variable to view a violin plot. The default shows the density for all listing prices with no groupings. Using separate sliders, users can filter the listings by price, distance from city center, and minimum nights stay. Additionally, a scatterplot price against a dependent variable selected from a dropdown is presented with radial options for basic data transformations such as logarithmic, square root, and reciprocal so that the user can gauge a possible linear relation from the data.

For data analysis, users can enter select up to 5 dependent variables for which a linear regression is run against price. The outputs shown to the user are adjusted R-squared, coefficient estimates, p-values for the estimates, a QQ-plot for the standardized residuals, and a scatterplot of fitted values to observations. Finally, the user can then enter in a value for each dependent variable and see the price that the model predicts for a listing with those criteria.

### Usage Scenarios

Maria lives in Barcelona and has accepted a temporary assignment from her company to work in Canada for 6-months. She wants to rent out her apartment during this time and decides to use Airbnb.com. Maria wants to choose a listing price that is competitive, but does not want to list too low. She knows her apartment is in a very desirable neighourhood for tourists, and thinks short-term rentals can maximize her profit. In order to select her price, she wants to be able to compare her apartment to similar Airbnb listings that consider a variety of characteristics and wants to write a description that emphasizes those characteristics most strongly related to higher listing prices. If Maria visits our dashboard, she can filter listings to those in her neighbourhood for an entire home to get an idea of the listing prices of comparables. She then decides to create a model to predict the mean listing price for accommodations with the same criteria as her apartment. Maria does not fully understand all of the output from the linear regression model, but understands that she can input her apartment's charateristics into the dashboard and get a prediction of the mean listing price for her similar apartments.
