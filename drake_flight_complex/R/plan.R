plan <- drake_plan(
  all_flights = GetAllFlights(),
  important_airports = GetImportantAirports(all_flights),
  urls = target(MakeParametricReport(important_airports), dynamic = cross(important_airports)),
  working_airports = gsub("airport_","", gsub(".html", "", urls[!is.na(urls)])),
  summaries = target(SummarizeAirport(working_airports, all_flights), dynamic=cross(working_airports)),
  summary=rmarkdown::render(
     knitr_in("airport_overview.Rmd"),
     output_file = file_out(paste0("../docs/airport_overview.html")),
     params = list(summaries=summaries),
     quiet = TRUE
   ),
   site = RenderSite(summaries, summary)
)
