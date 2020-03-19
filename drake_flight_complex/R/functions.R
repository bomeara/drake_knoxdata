GetAllFlights <- function() {
  flights <- readr::read_csv("../data/flightsDec2019.zip")
  flights[is.na(flights)] <- 0
  return(flights)
}

GetImportantAirports <- function(all_flights, min_flights=3000, max_flights=100000) {
  all_airport_flights <- c(all_flights$ORIGIN, all_flights$DEST)
  sorted <- sort(table(all_airport_flights), decreasing=TRUE)
  sorted_important <- sorted[sorted>=min_flights]
  sorted_important <- sorted_important[sorted_important<=max_flights]

  return(sort(names(sorted_important)))
}

GetFocalFlights <- function(focal_airport="TYS", flights) {
  focal_outbound <- subset(flights, ORIGIN==focal_airport)
  focal_outbound$Direction <- "Outbound"
  focal_outbound$TAXI_LOCAL <- focal_outbound$TAXI_OUT

  focal_inbound <- subset(flights, DEST==focal_airport)
  focal_inbound$Direction <- "Inbound"
  focal_inbound$TAXI_LOCAL <- focal_inbound$TAXI_IN

  focal_flights <- rbind(focal_outbound, focal_inbound)
  return(focal_flights)
}

HistogramPlot <- function(delay, focal_flights) {
  p<-ggplot(focal_flights, aes_string(x=delay, color="Direction")) +
    geom_freqpoly(binwidth=15, position="identity" , alpha=0.7)+
    theme(legend.justification=c(1,1), legend.position=c(0.95, 0.95)) + scale_y_log10() + xlim(0, NA) + scale_color_viridis_d(end=0.7) + xlab("Minutes delay") + ylab("Number of flights") + ggtitle(tolower(gsub("_", " ",delay)))
    return(p)
}

PlotDelays <- function(focal_flights) {
  delays <- colnames(focal_flights)[grepl("DELAY", colnames(focal_flights))]
  delays <- delays[!delays %in% c("DEP_DELAY", "ARR_DELAY")]

  all_plots <- lapply(delays, HistogramPlot, focal_flights=focal_flights)

  print(cowplot::plot_grid(plotlist=all_plots, nrow=2))
}

SummarizeAirport <- function(focal_airport, all_flights) {
  focal_flights <- GetFocalFlights(focal_airport, all_flights)
  result <- data.frame(
    airport=paste0('[', focal_airport, '](airport_', focal_airport, ".html)"),
    airport_location=subset(focal_flights, ORIGIN==focal_airport)$ORIGIN_CITY_NAME[1],
    total_outbound=nrow(subset(focal_flights, Direction=="Outbound")),
    total_inbound=nrow(subset(focal_flights, Direction=="Inbound")),
    median_departure_delay=round(median(focal_flights$DEP_DELAY, na.rm=TRUE)),
    mean_departure_delay=round(mean(focal_flights$DEP_DELAY, na.rm=TRUE)),
    median_arrival_delay=round(median(focal_flights$ARR_DELAY, na.rm=TRUE)),
    mean_arrival_delay=round(mean(focal_flights$ARR_DELAY, na.rm=TRUE)),
    stringsAsFactors=FALSE
  )
  return(result)
}


PlotTotalsDaily <- function(focal_flights) {
  totals_daily <- focal_flights %>% group_by(FL_DATE, Direction) %>% tally()
  totals_daily_plot <- ggplot(totals_daily, aes(x=FL_DATE,  y=n, color=Direction)) +  geom_line() + scale_color_viridis_d(end=0.7) + xlab("Date") + ylab("Number of flights")
  print(totals_daily_plot)
}

PlotTotalsByDay <- function(focal_flights) {
  totals_by_day <- focal_flights %>% group_by(DAY_OF_WEEK, Direction) %>% tally()
  totals_by_day_plot <- ggplot(totals_by_day, aes(x=DAY_OF_WEEK,  y=n, color=Direction)) +  geom_line() + scale_color_viridis_d(end=0.7) + ylab("Number of flights") + scale_x_continuous(breaks=c(1:7), labels=c("Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"))  + xlab("Day of week")
  print(totals_by_day_plot)
}

MakeParametricReport <- function(focal_airport) {
  output <- paste0("airport_", focal_airport, ".html")
  report <- rmarkdown::render(
     knitr_in("airport.Rmd"),
     output_file = file_out(paste0("../docs/airport_", focal_airport, ".html")),
     params = list(focal_airport=focal_airport),
     quiet = TRUE
    )
 return(output)
}

RenderSite <- function(summaries, summary) {
  rmarkdown::render_site(input="../docs")
}
