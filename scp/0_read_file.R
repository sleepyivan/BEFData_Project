
file_loc <- list(
  eu = "data/raw/Milk Prices Overview-EU.php",
  global = "data/raw/Milk Prices Overview-global.php"
)
file_dat <- map(file_loc, read_csv)

selected_country <- c("Germany", "Spain", "France", "Italy", "Poland", "Netherlands", "Ireland") |> 
  countrycode(origin = "country.name", destination = "iso2c")

DF <- bind_rows(
  file_dat$eu |> 
    filter(country %in% c(selected_country, "EU")) |> 
    distinct(date, country, price),
  file_dat$global |> 
    filter(country %in% c("XX")) |> 
    distinct(date, country, price)
)

df <- bind_rows(
  DF |> 
    filter(country %in% c("EU", "XX")) |> 
    mutate(
      country = case_match(country, "EU" ~ "EUROPE", "XX" ~ "GLOBAL")
    ),
  DF |> 
    filter(!country %in% c("EU", "XX")) |> 
    mutate(
      country = countrycode(country, origin = "iso2c", destination = "country.name")
    )
)

write_rds(df, "data/cache/tbl-selected_country_price.rds")

ts <- list(
  italy = df |> filter(country == "Italy") |> pull(price) |> ts(start = 2014, frequency = 12),
  europe = df |> filter(country == "EUROPE") |> pull(price) |> ts(start = 2014, frequency = 12),
  global = df |> filter(country == "GLOBAL") |> pull(price) |> ts(start = 2016, frequency = 12)
)

write_rds(ts, "data/cache/ts-italy.rds")


