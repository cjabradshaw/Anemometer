## install ansiweather in command line (via one of following: OpenBSD, NetBSD, FreeBSD, Debian, Ubuntu, Homebrew)
## ansiweather fetches weather data from OpenWeatherMap (https://openweather.org) free API
## ansiweather manual: https://github.com/fcambus/ansiweather
## R script requires libraries: jsonlite, processx, lutz, lubridate; pre-install in R via:
## > install.packages(c("jsonlite", "processx", "lutz", "lubridate"))

## pre-load city file (could add to function, but slows processing down considerably; best to load before running function)
## reference country code list: https://www.statdns.com/cctlds/
## city source JSON files: https://bulk.openweathermap.org/sample/
cityfile <- jsonlite::fromJSON(gzcon(url("https://bulk.openweathermap.org/sample/city.list.json.gz"))) # list of places used by ansiweather

# function
windDir.func <- function(Place, PlaceFile=cityfile) # where 'Place' is a city character string ('city,2-digit ISO country code') e.g., 'Adelaide,AU'

{
  raw.dat <- capture.output(temp1 <- processx::run('ansiweather', c("-l", Place, "-w", "true", "-d", "false", "-p", "false", "-h",
                                                                 "false", "-s", "false", "-a", "false"), error_on_status = FALSE, echo=T))
  dat <- scan(text = raw.dat, what = "")
  wdir <- dat[length(dat)] # wind direction
  wspeed <- as.numeric(dat[length(dat)-2]) # wind speed m/s
  wspeed.kmhr <- round(wspeed*3600/1000, 1) # wind speed km/hr
  temp <- as.numeric(dat[4])
  
  ## local time at Place
  Place2 <- scan(text=Place, what="", sep=",")
  coords <- PlaceFile[which(PlaceFile$name==Place2[1] & PlaceFile$country==Place2[2]),5]
  timezone <- lutz::tz_lookup_coords(coords$lat, coords$lon, method="accurate")[1]
  currentTime <- Sys.time()
  currentTimetz <- lubridate::with_tz(time=currentTime, tz=timezone)
  datePlace <- format(strptime(as.Date(lubridate::date(currentTimetz)), format="%Y-%m-%d"), "%d %b %Y")
  hourPlace <- sprintf("%02d", lubridate::hour(currentTimetz))
  minPlace <-  sprintf("%02d", lubridate::minute(currentTimetz))

  ## arrow coordinates
  codex <- data.frame(dircode=c("N","NNE","NE","ENE","E","ESE","SE","SSE","S","SSW","SW","WSW","W","WNW","NW","NNW"),
                    degr=seq(0,337.5,22.5))
  wdegr <- codex[which(codex$dircode == wdir), 2]
  
  ## arrow.coords
  x0s <- c(5, 6.25, 7.5, 7.5, 7.5, 7.5, 7.5, 6.25, 5, 3.75, 2.5, 2.5, 2.5, 2.5, 2.5, 3.75)
  x1s <- c(5, 3.75, 2.5, 2.5, 2.5, 2.5, 2.5, 3.75, 5, 6.25, 7.5, 7.5, 7.5, 7.5, 7.5, 6.25)
  y0s <- c(7.5, 7.5, 7.5, 6.25, 5, 3.75, 2.5, 2.5, 2.5, 2.5, 2.5, 3.75, 5, 6.25, 7.5, 7.5)
  y1s <- c(2.5, 2.5, 2.5, 3.75, 5, 6.25, 7.5, 7.5, 7.5, 7.5, 7.5, 6.25, 5, 3.75, 2.5, 2.5)
  
  arrow.coords.dat <- data.frame(x0s, x1s, y0s, y1s, codex$dircode)
  dir.sub <- which(arrow.coords.dat$codex.dircode == wdir)

  colrs <- rev(RColorBrewer::brewer.pal(n=10, "Spectral"))
  minT <- -15 # min temp for colour scale
  maxT <- 35 # max temp for colour scale
  Ts <- seq(minT, maxT, (maxT-minT)/10)
  loTs <- Ts[1:(length(Ts)-1)]
  upTs <- Ts[2:length(Ts)]
  tcols.dat <- data.frame(loTs, upTs, colrs)
  temp.col <- tcols.dat[which(tcols.dat$loTs < temp & tcols.dat$upTs >= temp), ]$colrs # choose temperature colour (blue to red)
  if(is.null(temp.col)==T) {
    temp.col <- ifelse(temp < minT, colrs[1], colrs[length(colrs)])
  }
  
  # plot anemometer
  par(xaxt="n", yaxt="n", pty="s")
  arrow.width <- wspeed.kmhr/10 # arrow line width increases with increasing wind speed
  plot(0:10,0:10,pch=NULL,col=NULL,xlab="",ylab="")
  arrows(x0=arrow.coords.dat[dir.sub,1], y0=arrow.coords.dat[dir.sub,3], x1=arrow.coords.dat[dir.sub,2], 
         y1=arrow.coords.dat[dir.sub,4], col="red", lwd=arrow.width, angle=25, length=0.4)
  text(x=5, y=9, labels=paste(wspeed.kmhr, " km/hr", sep=""), adj=0.5, cex=1.5)
  text(x=5, y=1, labels=paste(wdegr, "º (", wdir,")", sep=""), adj=0.5, cex=1.5)
  text(x=0, y=10, labels=Place, adj=0, cex=0.7, col="blue")
  text(x=10, y=10, labels=paste(temp, " ºC", sep=""), adj=1, cex=0.7, col=temp.col, font=2)
  text(x=0, y=0, labels=datePlace, adj=0, cex=0.7, col="blue")
  text(x=10, y=0, labels=paste(hourPlace, ":", minPlace, sep=""), adj=1, cex=0.7, col="black")
  
  return(list(windSpeed = wspeed.kmhr, windDirection = wdir, temperature=temp, time=paste(hourPlace, ":", minPlace, sep="")))
}

# examples
windDir.func(Place="Uraidla,AU")

windDir.func("Darlington,AU")
windDir.func("Perth,AU")
windDir.func("Helsinki,FI")
windDir.func("Wellington,NZ")
windDir.func("Vancouver,CA")
windDir.func("Ushuaia,AR")
