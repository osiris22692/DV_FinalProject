require("jsonlite")
require("RCurl")
# Change the USER and PASS below to be your UTEid
df <- data.frame(fromJSON(getURL(URLencode('skipper.cs.utexas.edu:5001/rest/native/?query="SELECT LEADINGCAUSESOFDEATH.YEARDATA, FREEZIPCODEDATABASE.CITYDATA, LEADINGCAUSESOFDEATH.CAUSES_OF_DEATH                                      From FREEZIPCODEDATABASE JOIN LEADINGCAUSESOFDEATH On FREEZIPCODEDATABASE.Zipcode = LEADINGCAUSESOFDEATH.Zip_Code;"'),httpheader=c(DB='jdbc:oracle:thin:@sayonara.microlab.cs.utexas.edu:1521:orcl', USER='C##cs329e_jzp78', PASS='orcl_jzp78', MODE='native_mode', MODEL='model', returnDimensions = 'False', returnFor = 'JSON'), verbose = TRUE), ))

