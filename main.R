

# LIBRARY -----------------------------------------------------------------

library(tidyverse)
library(scales)
library(patchwork)
library(gridExtra)
library(countrycode)

library(forecast)
library(zoo)
library(gam)
library(prophet)
library(DIMORA)


# MAIN --------------------------------------------------------------------

sys.source("scp/0_read_file.R", envir = env())
sys.source("scp/1-exploratory_data_analysis.R", envir = env())
source("scp/2-model_training.R")
source("scp/3-model_evaluation.R")
