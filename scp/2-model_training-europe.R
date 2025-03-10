
file_loc <- "data/cache/ts-italy.rds"
file_dat <- read_rds(file_loc)

ts_data <- file_dat$europe |> window(2016)

model <- list()

# ARIMA -------------------------------------------------------------------

model$arima <- auto.arima(ts_data)

# PROPHET -----------------------------------------------------------------

ts_df <- data.frame(
  ds = as.Date.ts(ts_data),
  y = as.numeric(ts_data)
)

model$prophet <- prophet(ts_df)


# BM ----------------------------------------------------------------------
# BM
# GBM
# GGM to be decide

model$bm <- BM(ts_data)

# OUTPUT ------------------------------------------------------------------
write_rds(model, "data/model_output/model-europe.rds")

