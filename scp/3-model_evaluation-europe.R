

# LOAD DATA ---------------------------------------------------------------

file_loc <- "data/model_output/model-europe.rds"
file_dat <- read_rds(file_loc)

DF <- tibble(
  ds = as.Date.ts(file_dat$arima$x),
  y = as.numeric(file_dat$arima$x),
  y_arima = fitted(file_dat$arima),
  y_prophet = predict(file_dat$prophet)[["yhat"]],
  # y_bm = file_dat$bm$fitted
) |> 
  mutate(
    y_arima_residual = y_arima - y,
    y_prophet_residual = y_prophet - y,
    # y_bm_residual = y_bm - y
  )

df_mse <- DF |> 
  reframe(
    y_arima_mse = mean(y_arima_residual^2),
    y_prophet_mse = mean(y_prophet_residual^2),
    # y_bm_mse = mean(y_bm_residual^2)
  ) |> 
  pivot_longer(cols = everything(), names_to = "Model", values_to = "MSE") |> 
  mutate(
    MSE = round(MSE, 2),
  )

df <- DF |> 
  select(-ends_with("residual")) |> 
  pivot_longer(cols = -ds, names_to = "model", values_to = "price") |> 
  mutate(
    model = case_match(
      model,
      "y" ~ "ORIGINAL",
      "y_arima" ~ "ARIMA",
      "y_prophet" ~ "PROPHET",
      # "y_bm" ~ "BASS MODEL",
    )
  )

# FITTED CHART ------------------------------------------------------------
drawFittedModel <- function(DF) {
  p <- DF |> 
    ggplot() +
    geom_line(data = ~ filter(., model == "ORIGINAL"), aes(x = ds, y = price), color = "black",) +
    geom_line(data = ~ filter(., model != "ORIGINAL"), aes(x = ds, y = price, color = model), alpha = 0.7) +
    scale_x_date(date_labels = "%Y", date_breaks = "1 year") +
    scale_color_brewer(type = "qual", palette = 2) +
    theme_classic() +
    theme(
      panel.grid.major.y = element_line()
    )
  p +
    labs(x = "Year", y = "Price (€/100kg)", color = "Model")
}


drawFittedModel(df) +
  annotation_custom(tableGrob(df_mse, rows = NULL), xmin = as_date("2016-01-01"), xmax = as_date("2019-01-01"), ymin = 50, ymax=55)

# OUTPUT ------------------------------------------------------------------
ggsave("pics/fig-model-europe.png",  width = 9, height = 4)



