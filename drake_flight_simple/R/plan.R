plan <- drake_plan(
  focal_flights = GetFocalFlights(),
  plot_delays = PlotDelays(focal_flights),
  plot_totals_daily = PlotTotalsDaily(focal_flights),
  plot_totals_by_day = PlotTotalsByDay(focal_flights)
)
