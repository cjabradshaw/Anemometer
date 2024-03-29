# Anemometer function in R

<img align="right" src="www/AnemometerEx.png" alt="Anemometer" width="300" style="margin-top: 20px">

A handy function to create a simple anemometer plot for anywhere in the world in R. 

## Installation & Set-up
1. Install <code>ansiweather</code> in the command line (Terminal) via any one of following: <a href="https://www.openbsd.org">OpenBSD</a>, <a href="https://www.netbsd.org">NetBSD</a>, <a href="https://www.freebsd.org">FreeBSD</a>, <a href="https://www.debian.org">Debian</a>, <a href="https://ubuntu.com">Ubuntu</a>, or <a href="https://brew.sh">Homebrew</a>. I use <a href="https://brew.sh">Homebrew</a> on my Mac via: $ <code>brew install ansiweather</code>

<code>ansiweather</code> fetches weather data from <a href="https://openweather.org">OpenWeatherMap</a>'s free API

Access <code>ansiweather</code>'s <a href="https://github.com/fcambus/ansiweather">manual</a> for more information

2. Install the following libraries in R:
- <code><a href="https://cran.r-project.org/web/packages/jsonlite/index.html">jsonlite</a></code>
- <code><a href="https://cran.r-project.org/web/packages/processx/index.html">processx</a></code>
- <code><a href="https://andyteucher.ca/lutz/">lutz</a></code>
- <code><a href="https://lubridate.tidyverse.org/">lubridate</a></code>
- <code><a href="https://cran.r-project.org/web/packages/caroline/index.html/">caroline</a></code>
- <code><a href="https://rlang.r-lib.org">rlang</a></code>
- <code><a href="https://cran.r-project.org/web/packages/rgbif/index.html">rgbif</a></code>

You can do this easily with the following command:
> <code>install.packages(c("jsonlite", "processx", "lutz", "lubridate", "caroline", "rlang", "rgbif"))</code>

3. Pre-load the city file, which is the location <a href="https://www.json.org/json-en.html">JSON</a> (Javascript Object Notation) database <code>ansiweather</code> uses to identify place names. You could add this to the function itself, but it slows processing down considerably, so it's best to load before running the function.

> <code>cityfile <- jsonlite::fromJSON(gzcon(url("https://bulk.openweathermap.org/sample/city.list.json.gz")))</code>
  
The 2-digit ISO country code can be found <a href="https://www.statdns.com/cctlds/">here</a>, and you can access various versions and scales of the source JSON database <a href="https://www.statdns.com/cctlds/">here</a>.

4. Should you wish the elevation (metres above sea level; 'm asl') of the location to be displayed on the plot, you will need to register for a free user name on the <a href="https://www.geonames.org/">GeoNames</a> geographical database. Once you approve your account, ensure that you enable free webservices on your '<a href="https://www.geonames.org/manageaccount">manage account</a>' page.
  
5. Run both the functions <code>plotCompass</code> and <code>AnemometerFunction</code> in R (the former is invoked by the latter; both scripts are included together in <code>AnemometerFunction.R</code>), then you're ready to plot a real-time anemometer (including windspeed, wind direction temperature, humidity, air pressure, latitude, longitude, date, time, and elevation (optional) as in the example plot above).
  
Note: if you registered at GeoNames, you need to include your user name using the option <code>GEONAMES_USERNAME="my_user_name"</code>; if you do not provide a user name, the elevation will return 'no elev data' in the plot.
  
Some examples:

- <code>AnemometerFunc(Place="Adelaide,AU", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Darlington,AU", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Hobart,AU", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Perth,AU", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Port Moresby,PG", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Dunedin,NZ", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Wellington,NZ", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Sapporo,JP", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Helsinki,FI", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Paris,FR", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Kyiv,UA", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Reykjavik,IS", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Vancouver,CA", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Whitehorse,CA", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Sachs Harbour,CA", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Rimouski,CA", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Ushuaia,AR", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Punta Arenas,CL", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Agadez,NE", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Dar es Salaam,TZ", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Phalaborwa,ZA", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Kolkata,IN", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
- <code>AnemometerFunc(Place="Bengaluru,IN", PlaceFile=cityfile, GEONAMES_USERNAME="my_user_name")</code><br>
  
  
<img align="right" src="www/windicon.png" alt="Thylacoleo" width="300" style="margin-top: 20px">

Note that the arrow's line width varies as a function of windspeed (thicker with higher speeds), that the colour of the temperature text (<strong>T</strong>) on the plot varies from blue to red (cold to hot), that the humidity (<strong>H</strong>) display varies from yellow to dark blue (dry to wet), and that the pressure (<strong>P</strong>) ranges from dark red, red, pink, to orange (very low, low, moderate, high).
  
<br>
Prof <a href="http://scholar.google.com.au/citations?sortby=pubdate&hl=en&user=1sO0O3wAAAAJ&view_op=list_works">Corey J. A. Bradshaw</a> <br>
<a href="http://globalecologyflinders.com" target="_blank">Global Ecology</a>, <a href="http://flinders.edu.au" target="_blank">Flinders University</a>, Adelaide, Australia <br>
March 2022 <br>
<a href=mailto:corey.bradshaw@flinders.edu.au>e-mail</a> <br>
  

