

# LOAD DATA ---------------------------------------------------------------

file_loc <- "data/model_output/model-italy.rds"
file_dat <- read_rds(file_loc)

DF <- file_dat$arima |> 
  map(~ predict(., 13) |> keep_at("pred") |> list_c()) |> 
  data.frame() |> 
  as_tibble() |> 
  mutate(
    ds = seq.Date(date("2024-12-01"), date("2025-12-01"), by = "month"),
    .before = everything()
  )

df <- DF |> 
  mutate(
    Italy_predict = predict(file_dat$gam, DF)
  )

