plan <- drake_plan(
  all_flights = GetAllFlights(),
  focal_flights = GetFocalFlights(focal_airport="TYS", flights=all_flights),
  plot_delays = PlotDelays(focal_flights),
  plot_totals_daily = PlotTotalsDaily(focal_flights),
  plot_totals_by_day = PlotTotalsByDay(focal_flights),
  report = rmarkdown::render(
   knitr_in("airport.Rmd"),
   output_file = file_out("airport.html"),
   params = list(focal_airport="TYS"),
   quiet = TRUE
 )
)
