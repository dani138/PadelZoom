# List of packages for session
.packages = c("googleAnalyticsR","ggplot2","plyr","dplyr","tidyr")

# Install CRAN packages (if not already installed)
.inst <- .packages %in% installed.packages()
if(length(.packages[!.inst]) > 0) install.packages(.packages[!.inst])

# Load packages into session 
lapply(.packages, require, character.only=TRUE)

ga_auth()

# todas las sesiones

id = "ga:132914893"
startdate = "2017-01-01"
enddate = "2017-03-31"
metrics = c("sessions")
dimensions = c("devicecategory")
filters = c("")
segments = c("")


sesiones <- google_analytics(id = id,
                                  start = startdate,
                                  end = enddate,
                                  dimensions = dimensions,
                                  metrics = metrics,
                                  max_results = 1000)

# ficha de producto

segments = c("sessions::condition::ga:contentGroup1==Pagina de Pala")

fichaproducto <- google_analytics(id = id,
                            start = startdate,
                            end = enddate,
                            dimensions = dimensions,
                            metrics = metrics,
                            segment = segments,
                            max_results = 1000)

# click en comprar

segments = c("sessions::condition::ga:goal1Completions>0")

clickcomprar <- google_analytics(id = id,
                                 start = startdate,
                                 end = enddate,
                                 dimensions = dimensions,
                                 metrics = metrics,
                                 segment = segments,
                                 max_results = 1000)


# join de las tablas

funnel <- join_all(list(sesiones,fichaproducto,clickcomprar),"devicecategory")

names(funnel) <- c("devicecategory","sesiones","fichaproducto","clickcomprar")

funnel <- funnel %>% gather(pasofunnel, sesiones, sesiones:clickcomprar)

totaldesktop <- max(funnel$sesiones[funnel$devicecategory=="desktop"])
totalmobile <- max(funnel$sesiones[funnel$devicecategory=="mobile"])
totaltablet <- max(funnel$sesiones[funnel$devicecategory=="tablet"])

funnel$padding[funnel$devicecategory=="desktop"] <- (totaldesktop - funnel$sesiones[funnel$devicecategory=="desktop"]) / 2
funnel$padding[funnel$devicecategory=="mobile"] <- (totalmobile - funnel$sesiones[funnel$devicecategory=="mobile"]) / 2
funnel$padding[funnel$devicecategory=="tablet"] <- (totaltablet - funnel$sesiones[funnel$devicecategory=="tablet"]) / 2


funnel$pasofunnel <-  factor(funnel$pasofunnel, ordered = T, levels = c("clickcomprar","fichaproducto","sesiones"))

funnel <- funnel %>% gather(variable, value, c(sesiones,padding))

funnel$variable <- factor(funnel$variable, ordered = T, levels = c("sesiones","padding"))

funnel$rate[funnel$devicecategory=="desktop"] <- funnel$value[funnel$devicecategory=="desktop"]/totaldesktop*100
funnel$rate[funnel$devicecategory=="mobile"] <- funnel$value[funnel$devicecategory=="mobile"]/totalmobile*100
funnel$rate[funnel$devicecategory=="tablet"] <- funnel$value[funnel$devicecategory=="tablet"]/totaltablet*100

funnel$rate2 <- 100

# bucle para a?adir porcentajes

n <- 4
i <- 1
for(i in 1:12) {
        funnel$rate2[n] <- funnel$value[n]/funnel$value[n-3]*100
        n <- n+1
}


pruebafunnel <- filter(funnel, variable == "sesiones")

ggplot(funnel, aes(x = pasofunnel)) + 
        geom_bar(aes(y = value, fill = variable), stat = "identity", position = "stack") + 
        facet_wrap(~devicecategory, scales = "free") +
        coord_flip() +
        scale_fill_manual(values = c("yellow",NA)) +
        geom_text(data = pruebafunnel, aes(y = 1000, label = paste(round(rate, 2), "%")), color = "black") +
        #geom_text(data = pruebafunnel, aes(y = 6000, label = paste(round(rate2, 2), "%")), color = "black") +
        theme(legend.position = "none") +
        labs(x = "Paso del Funnel",
             y = "Sesiones", 
             title = "Funnel de conversión por categoría de dispositivo",
             caption = "Fuente: Google Analytics") +
        theme_minimal() +
        theme(legend.position = "none")
