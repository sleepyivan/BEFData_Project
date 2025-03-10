
# LOAD DATA ---------------------------------------------------------------
file_loc <- list(
  df = "data/cache/tbl-selected_country_price.rds",
  ts = "data/cache/ts-italy.rds"
)
file_dat <- map(file_loc, read_rds)

# TS DATA ITALY VS TOTAL --------------------------------------------------

ts_data <- ts.union(file_dat$ts$italy, file_dat$ts$europe, file_dat$ts$global)
colnames(ts_data) <- c("Italy", "EUROPE", "GLOBAL")

ts_data |> 
  autoplot() +
  scale_color_brewer(type = "qual", palette = 7) +
  scale_x_continuous(breaks = 2014:2025) +
  theme_classic() +
  theme(
    panel.grid.major.y = element_line(),
    legend.position = "top"
  ) +
  labs(
    title = "Italy Farm-gate Milk price comparing to Europe and Global",
    x = "Year", y = "Price (€/100kg)", color = "Legend"
  )
ggsave("pics/fig-eda-italy_eu_global.png", width = 9, height = 4)


# DF ITALY VS EU MEMBER STATES --------------------------------------------

DF <- file_dat$df |> 
  mutate(
    country = fct_reorder(country, price)
  )

DF |> 
  filter(!country %in% c("EUROPE", "GLOBAL")) |> 
  ggplot(aes(x = date, y = price, group = country)) +
  geom_point(alpha = 0.6) +
  geom_line(aes(color = country)) +
  theme_classic() +
  theme(
    panel.grid.major.y = element_line(),
    legend.position = "top"
  )

df <- DF |> 
  filter(!country %in% c("GLOBAL", "EUROPE")) |> 
  pivot_wider(names_from = country, values_from = price) |> 
  mutate(
    Germany =  Germany - Italy,
    Ireland =  Ireland - Italy,
    Spain =  Spain - Italy,
    France = France - Italy,
    Netherlands =  Netherlands - Italy,
    Poland = Poland - Italy,
    Italy = Italy - Italy
  ) |> 
  pivot_longer(cols = -date, names_to = "country", values_to = "price") |> 
  mutate(
    country = factor(country, levels = c("Poland", "Spain", "Ireland", "Italy", "Germany", "France", "Netherlands"))
  )

df |>   
  ggplot(aes(x = date, y = price, group = country)) +
  geom_point(alpha = 0.6) +
  geom_line(aes(color = country)) +
  scale_color_brewer(type = "div", palette = 4) +
  guides(color = guide_legend(nrow = 1)) +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y") +
  theme_classic() +
  theme(
    panel.grid.major.y = element_line(),
    legend.position = "top"
  ) +
  labs(
    title = "Price Difference between Italy and major producers of EU member states",
    x = "Year", y = "Diffrence of Price", color = "Country"
  )

ggsave("pics/fig-eda-italy_countries.png", width = 9, height = 5)
  
  
  
  
  
  
  
