library(googleAnalyticsR)
library(plyr)
library(ggplot2)

ga_auth()

id = "ga:132914893"
startdate = "2017-02-01"
enddate = "2017-02-19"
metrics = c("goal1Completions")
dimensions = c("ga:yearmonth")
filters =
segments = 

febrero <- google_analytics(id = id,
                           start = startdate,
                           end = enddate,
                           metrics = metrics,
                           dimensions = dimensions)

startdate = "2017-03-01"
enddate = "2017-03-19"

marzo <- google_analytics(id = id,
                            start = startdate,
                            end = enddate,
                            metrics = metrics,
                            dimensions = dimensions)

startdate = "2017-02-01"
enddate = "2017-02-19"
metrics = c("ga:sessions")
dimensions = c("yearmonth")
filters = c("ga:dimension1==Pagina de pala")

febrero2 <- google_analytics(id = id,
                             start = startdate,
                             end = enddate,
                             metrics = metrics,
                             dimensions = dimensions,
                             filters = filters)

startdate = "2017-03-01"
enddate = "2017-03-19"

marzo2 <- google_analytics(id = id,
                                       start = startdate,
                                       end = enddate,
                                       metrics = metrics,
                                       dimensions = dimensions,
                                       filters = filters)

febrero_marzo <- join_all(list(febrero,febrero2,marzo,marzo2), by = "yearmonth", type = "full")

febrero_marzo[2,3] <- marzo2[1,2]

ggplot(febrero_marzo, aes(x = yearmonth)) +
        geom_point(aes(y = goal1Completions), color = "blue") + 
        geom_point(aes(y = sessions), color = "red")
