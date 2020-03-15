library(tidyverse)
library(plyr)
library(cowplot)


# Data downloaded from https://transtats.bts.gov/DL_SelectFields.asp; latest available was Dec. 2019.
flights <- readr::read_csv("../data/flightsDec2019.zip")
flights[is.na(flights)] <- 0

focal_airport <- "TYS"

focal_outbound <- subset(flights, ORIGIN==focal_airport)
focal_outbound$Direction <- "Outbound"
focal_outbound$TAXI_LOCAL <- focal_outbound$TAXI_OUT

focal_inbound <- subset(flights, DEST==focal_airport)
focal_inbound$Direction <- "Inbound"
focal_inbound$TAXI_LOCAL <- focal_inbound$TAXI_IN

focal_flights <- rbind(focal_outbound, focal_inbound)


# mu <- plyr::ddply(focal_flights, "Direction", summarise, grp.median=stats::median(TAXI_LOCAL, na.rm=TRUE))

# p<-ggplot(focal_flights, aes(x=TAXI_LOCAL, color=Direction)) +
#   geom_density()+
#   theme(legend.position="top")
# p

HistogramPlot <- function(delay, focal_flights) {
  p<-ggplot(focal_flights, aes_string(x=delay, color="Direction")) +
    geom_freqpoly(binwidth=15, position="identity" , alpha=0.7)+
    theme(legend.justification=c(1,1), legend.position=c(0.95, 0.95)) + scale_y_log10() + xlim(0, NA) + scale_color_viridis_d(end=0.7) + xlab("Minutes delay (15 min increments)") + ylab("Number of flights") + ggtitle(tolower(gsub("_", " ",delay)))
    return(p)
}

delays <- colnames(focal_flights)[grepl("DELAY", colnames(focal_flights))]
delays <- delays[!delays %in% c("DEP_DELAY", "ARR_DELAY")]

cowplot::plot_grid(lapply(delays, HistogramPlot, focal_flights=focal_flights), nrow=2)
