

# LOAD DATA ---------------------------------------------------------------
file_loc <- "data/model_output/model-italy.rds"
file_dat <- read_rds(file_loc)

DF <- file_dat$gam$data |> 
  select(
    ds = date,
    y = Italy
  ) |> 
  bind_cols(
    y_gam = file_dat$gam$fitted.values
  ) |> 
  mutate(
    y_gam_residual = y_gam - y,
  )

df_mse <- DF |> 
  reframe(
    y_gam_mse = mean(y_gam_residual^2)
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
      "y_gam" ~ "GAM"
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
  annotation_custom(tableGrob(df_mse, rows = NULL), xmin = as_date("2014-01-01"), xmax = as_date("2017-01-01"), ymin = 50, ymax=55)

# OUTPUT ------------------------------------------------------------------
ggsave("pics/fig-model-italy.png",  width = 9, height = 4)



