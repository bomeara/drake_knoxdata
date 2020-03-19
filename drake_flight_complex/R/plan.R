plan <- drake_plan(
  all_flights = GetAllFlights(),
  report = rmarkdown::render(
   knitr_in("airport.Rmd"),
   output_file = file_out("../docs/airport.html"),
   params = list(focal_airport="TYS"),
   quiet = TRUE
 )
)
