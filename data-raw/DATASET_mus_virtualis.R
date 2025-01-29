library(tidyverse)
shp_example <- sf::read_sf("data-raw/shp_example.shp")
presence_pts <- sf::st_read("data-raw/presence_pts.kml") %>%
  sf::st_cast("POINT") %>%
  sf::st_coordinates() %>%
  as.data.frame() %>%
  rename(latitude = Y, longitude = X) %>%
  mutate(name = "Mus virtualis") %>%
  mutate(presence = 1) %>%
  select(name, latitude, longitude, presence)

absence_pts <- sf::st_read("data-raw/absenceses_pts.kml") %>%
  sf::st_cast("POINT") %>%
  sf::st_coordinates() %>%
  as.data.frame() %>%
  rename(latitude = Y, longitude = X) %>%
  mutate(name = "Mus virtualis") %>%
  mutate(presence = 0) %>%
  select(name, latitude, longitude, presence)
mus_virtualis <- bind_rows(presence_pts, absence_pts)
mus_virtualis_pts <- mus_virtualis %>%
  sf::st_as_sf(coords = c("longitude", "latitude"))
sf::st_crs(mus_virtualis_pts) <- sf::st_crs(shp_example)

write_csv(mus_virtualis, "data-raw/mus_virtualis.csv")
dir.create("data-raw/mus_virtualis/")
sf::write_sf(mus_virtualis_pts, "data-raw/mus_virtualis/mus_virtualis.shp")

usethis::use_data(mus_virtualis)

sink("R/mus_virtualis.R")
cat(sinew::makeOxygen(obj = mus_virtualis, add_fields = c("title", "description", "details")))
sink()

