# List of packages for session
.packages = c("googleAnalyticsR","ggplot2")

# Install CRAN packages (if not already installed)
.inst <- .packages %in% installed.packages()
if(length(.packages[!.inst]) > 0) install.packages(.packages[!.inst])

# Load packages into session 
lapply(.packages, require, character.only=TRUE)

ga_auth()

id = "ga:132914893"
startdate = "2017-01-01"
enddate = "2017-03-31"
metrics = c("sessions","goal1Completions","goal1ConversionRate","bouncerate")
dimensions = c("devicecategory")
filters = c("")
segments = c("")
        
categoriadispositivo <- google_analytics(id = id,
                                start = startdate,
                                end = enddate,
                                metrics = metrics,
                                dimensions = dimensions)

ggplot(categoriadispositivo) +
        geom_point(aes(x = goal1ConversionRate, y = bouncerate, color = devicecategory, size = sessions)) +
        scale_size_continuous("sessions", range = c(1,30)) +
        labs(x = "Tasa de conversión (%)", y = "Tasa de rebote (%)")


# grafico de sectores

pie(categoriadispositivo$sessions, labels = categoriadispositivo$devicecategory)

# De donde vienen en cada dispositivo (en principio se puede omitir o modificar)

dimensions = c("devicecategory","channelGrouping")

categoriadispositivo2 <- google_analytics(id = id,
                               start = startdate,
                               end = enddate,
                               metrics = metrics,
                               dimensions = dimensions)

ggplot(categoriadispositivo2) +
        geom_point(aes(x = goal1ConversionRate, y = bouncerate, size = sessions, color = channelGrouping)) +
        facet_wrap(~devicecategory) +
        scale_size_continuous("sessions",range = c(1,30))
