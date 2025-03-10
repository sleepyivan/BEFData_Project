

# LOAD DATA ---------------------------------------------------------------

file_loc <- "data/cache/tbl-selected_country_price.rds"
file_dat <- read_rds(file_loc)

DF <- file_dat |> 
  filter(!country %in% c("EUROPE", "GLOBAL")) |> 
  pivot_wider(names_from = country, values_from = price)

ts_data <- DF |> 
  select(-date, -Italy) |> 
  map(~ ts(., start = 2014, frequency = 12))

model <- list()

# ARIMA -------------------------------------------------------------------

model$arima <- map(ts_data, auto.arima)


# GAM ---------------------------------------------------------------------
model$gam <- gam(Italy ~ s(Germany) + s(Ireland) + s(Spain) + s(France) + s(Netherlands) + s(Poland), data = DF)
# model$gam <- gam(Italy ~ lo(Germany) + lo(Ireland) + lo(Spain) + lo(France) + lo(Netherlands) + lo(Poland), data = DF)
model$gam <- gam(Italy ~ s(Germany, spar = 0.2) + s(Ireland) + s(Spain) + s(France, spar = 0.5) + s(Netherlands) + s(Poland), data = DF)


df <- DF |> 
  select(date, Italy) |> 
  bind_cols(fitted = model$gam$fitted.values)

ggplot(df, aes(x = date)) +
  geom_line(aes(y = Italy)) +
  geom_line(aes(y = fitted), color = "red")

write_rds(model, "data/model_output/model-italy.rds")

