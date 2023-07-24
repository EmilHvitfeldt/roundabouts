## code to prepare `roundabouts` dataset goes here

text <- readr::read_lines("data-raw/roundabout_export_7_24_2023.kml")
text <- paste0(text, collapse = "")
text <- stringr::str_squish(text)

roundabouts_raw <- stringr::str_extract_all(text, "<Placemark>.*?</Placemark>")[[1]]

extract_roundabout <- function(x) {
  name <- stringr::str_extract(x, "(?<=<name>)(.*?)(?=</name>)")
  address <- stringr::str_extract(x, "(?<=<address>)(.*?)(?=</address>)")
  coordinates <- stringr::str_extract(x, "(?<=<coordinates>)(.*?)(?=</coordinates>)")

  description <- stringr::str_extract(x, "(?<=<description>)(.*?)(?=</description>)")

  features <- setNames(
    stringr::str_extract_all(description, "(?<=<dd>)(.*?)(?=</dd>)")[[1]],
    stringr::str_extract_all(description, "(?<=<dt>)(.*?)(?=</dt>)")[[1]]
  ) |>
    as.list()

  c(name = name, address = address, coordinates = coordinates, features) |>
    tibble::new_tibble()
}

roundsabouts_lists <- purrr::map(roundabouts_raw, extract_roundabout)

roundabouts <- purrr::list_rbind(roundsabouts_lists)

roundabouts <- janitor::clean_names(roundabouts)

usethis::use_data(roundabouts, overwrite = TRUE)
