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
AnemometerFunc <- function(Place, PlaceFile=cityfile) # where 'Place' is a city character string ('city,2-digit ISO country code') e.g., 'Adelaide,AU'

{
  raw.dat <- capture.output(temp1 <- processx::run('ansiweather', c("-l", Place, "-w", "true", "-d", "false", "-p", "true", "-h",
                                                                 "true", "-s", "false", "-a", "false"), error_on_status = FALSE, echo=T))
  dat <- scan(text = raw.dat, what = "")
  pres <- as.numeric(dat[length(dat)-1]) # air pressure
  hum <- dat[length(dat)-4] # % humidity
  humN <- as.numeric(substr(hum,1,nchar(hum)-1)) # numerical humidity
  wdir <- dat[length(dat)-7] # wind direction
  wspeed <- as.numeric(dat[length(dat)-9]) # wind speed m/s
  wspeed.kmhr <- round(wspeed*3600/1000, 1) # wind speed km/hr
  temp <- as.numeric(dat[length(dat)-16]) # temperature
  
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
  arrow.width <- wspeed.kmhr/10 # arrow line width increases with increasing wind speed
  
  # temperature-dependent text colour
  tcolrs <- rev(RColorBrewer::brewer.pal(n=11, "RdBu"))[-c(5,6)]
  minT <- -15 # min temp for colour scale
  maxT <- 35 # max temp for colour scale
  Ts <- seq(minT, maxT, (maxT-minT)/length(tcolrs))
  loTs <- Ts[1:(length(Ts)-1)]
  upTs <- Ts[2:length(Ts)]
  tcols.dat <- data.frame(loTs, upTs, tcolrs)
  temp.col <- tcols.dat[which(tcols.dat$loTs < temp & tcols.dat$upTs >= temp), ]$tcolrs # choose temperature colour (blue to red)
  if(length(temp.col)==0) {
    temp.col <- ifelse(temp < minT, tcolrs[1], tcolrs[length(tcolrs)])
  }
  
  # humidity-dependent text colour
  hcolrs <- RColorBrewer::brewer.pal(n=9, "YlGnBu")[-c(1,2)]
  Hs <- seq(0, 100, 100/length(hcolrs))
  loHs <- Hs[1:(length(Hs)-1)]
  upHs <- Hs[2:length(Hs)]
  hcols.dat <- data.frame(loHs, upHs, hcolrs)
  h.col <- hcols.dat[which(hcols.dat$loHs < humN & hcols.dat$upHs >= humN), ]$hcolrs # choose humidity colour (yellow to blue)
  
  # pressure
  prestxt1 <- ifelse(pres < 980, "very low", ifelse(pres > 980 & pres <= 1000, "low", "moderate"))
  prestxt <- ifelse(pres > 1025, "high", prestxt1)
  prescolr1 <- ifelse(prestxt == "very low", "dark red", ifelse(prestxt == "low", "red", "pink"))
  prescolr <- ifelse(prestxt == "high", "orange", prescolr1)
  
  ## coordinates
  hemSN <- ifelse(sign(coords$lat)[1]==-1, "S", "N")
  hemEW <- ifelse(sign(coords$lon)[1]==-1, "W", "E")
  latDMS <- ifelse(hemSN=="S", paste(-ceiling(coords$lat), "º ", round((-(coords$lat-ceiling(coords$lat)))*60, 2), "′ ", hemSN, sep=""),
                   paste(floor(coords$lat), "º ", round(((coords$lat-floor(coords$lat)))*60, 2), "′ ", hemSN, sep=""))
  lonDMS <- ifelse(hemEW=="W", paste(-ceiling(coords$lon), "º ", round((-(coords$lon-ceiling(coords$lon)))*60, 2), "′ ", hemEW, sep=""),
                   paste(floor(coords$lon), "º ", round(((coords$lon-floor(coords$lon)))*60, 2), "′ ", hemEW, sep=""))
  
  # plot anemometer
  par(xaxt="n", yaxt="n", pty="s")
  plot(0:10,0:10,pch=NULL,col=NULL,xlab="",ylab="")
  arrows(x0=arrow.coords.dat[dir.sub,1], y0=arrow.coords.dat[dir.sub,3], x1=arrow.coords.dat[dir.sub,2], 
         y1=arrow.coords.dat[dir.sub,4], col="red", lwd=arrow.width, angle=25, length=0.4)
  text(x=5, y=9, labels=paste(wspeed.kmhr, " km/hr", sep=""), adj=0.5, cex=1.5)
  text(x=5, y=1, labels=paste(wdegr, "º (", wdir,")", sep=""), adj=0.5, cex=1.5)
  text(x=0, y=10, labels=Place, adj=0, cex=0.7, col="blue")
  text(x=10, y=10, labels=paste("T: ", temp, " ºC", sep=""), adj=1, cex=0.7, col=temp.col, font=2)
  text(x=10, y=9.5, labels=paste("H: ", hum, sep=""), adj=1, cex=0.7, col=h.col, font=2)
  text(x=10, y=9, labels=paste("P: ", prestxt, sep=""), adj=1, cex=0.7, col=prescolr, font=2)
  text(x=0, y=0, labels=datePlace, adj=0, cex=0.7, col="black")
  text(x=10, y=0, labels=paste(hourPlace, ":", minPlace, sep=""), adj=1, cex=0.7, col="black")
  text(x=0, y=9.5, labels=latDMS, adj=0, cex=0.6, col="black")
  text(x=0, y=9, labels=lonDMS, adj=0, cex=0.6, col="black")
  
    return(list(windSpeed = wspeed.kmhr, windDirection = wdir, temperature=temp, humidity=humN, airPressure=pres,
              latitude=coords$lat, longitude=coords$lon, time=paste(hourPlace, ":", minPlace, sep="")))
}

# examples
AnemometerFunc("Darlington,AU")
AnemometerFunc("Perth,AU")
AnemometerFunc("Helsinki,FI")
AnemometerFunc("Wellington,NZ")
AnemometerFunc("Vancouver,CA")
AnemometerFunc("Ushuaia,AR")
