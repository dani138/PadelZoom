# List of packages for session
.packages = c("googleAnalyticsR","ggplot2", "reshape")

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
dimensions = c("")
filters = c("")
segments = c("")

sesiones <- google_analytics(id = id,
                             start = startdate,
                             end = enddate,
                             metrics = metrics)

# ficha de producto

segment = c("sessions::condition::ga:contentGroup1==Pagina de Pala")

fichaproducto <- google_analytics(id = id,
                                  start = startdate,
                                  end = enddate,
                                  metrics = metrics,
                                  segment = segment,
                                  max_results = 1000)

# click en comprar

segment = c("sessions::condition::ga:goal1Completions>0")

clickcomprar <- google_analytics(id = id,
                                 start = startdate,
                                 end = enddate,
                                 metrics = metrics,
                                 segment = segment,
                                 max_results = 1000)

# modificando los datos para graficar

dat <- cbind(c("sesiones","fichaproducto","clickcomprar"),rbind(sesiones,fichaproducto,clickcomprar))
names(dat) <- c("steps","numbers")

dat$rate[dat$steps=="sesiones"] <- dat$numbers[dat$steps=="sesiones"]/dat$numbers[dat$steps=="sesiones"]*100
dat$rate[dat$steps=="fichaproducto"] <- dat$numbers[dat$steps=="fichaproducto"]/dat$numbers[dat$steps=="sesiones"]*100
dat$rate[dat$steps=="clickcomprar"] <- dat$numbers[dat$steps=="clickcomprar"]/dat$numbers[dat$steps=="sesiones"]*100

# add spacing, melt, sort
total <- subset(dat, rate==100)$numbers
dat$padding <- (total - dat$numbers) / 2
molten <- melt(dat[, -3], id.var='steps')
molten <- molten[order(molten$variable, decreasing = T), ]
molten$steps <- factor(molten$steps, ordered = T, levels = c("clickcomprar","fichaproducto","sesiones"))

# gráfico

ggplot(molten, aes(x=steps)) +
        geom_bar(aes(y = value, fill = variable),
                 stat='identity', position='stack') +
        geom_text(data=dat, 
                  aes(y=total/2, label= paste(round(rate), '%')),
                  color='black') +
        scale_fill_manual(values = c('lightblue', NA) ) +
        coord_flip()  +
        labs(x = "Paso del Funnel",
             y = "Sesiones", 
             title = "Funnel de conversión general",
             caption = "Fuente: Google Analytics") +
        theme_minimal() +
        theme(legend.position = 'none')
