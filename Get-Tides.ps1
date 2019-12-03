# API: http://tidesandcurrents.noaa.gov/api/
#  http://www.flaterco.com/xtide/faq.html
#  http://opendap.co-ops.nos.noaa.gov/axis/     !!

# 9447130
# ((Get-Date)).tostring("MM/dd/yyyy HH:mm"))

$url = "http://tidesandcurrents.noaa.gov/api/datagetter?"
#$url += "date=recent"
$url += "begin_date=" + ((Get-Date).AddHours(12)).tostring("MM/dd/yyyy HH:mm")
$url += "&range=12"
$url += "&station=9447905"
$url += "&product=water_level"
$url += "&datum=MLLW"
$url += "&units=english"
$url += "&time_zone=lst_ldt"
$url += "&application=web_services"
$url += "&format=json"

Write-Host $url

$response = Invoke-RestMethod -Uri $url


foreach ($entry in $response.data)
{
    #New-Object psObject -Property @{
    #    "WaterLevel": 
    $entry
}

Write-Host "ERROR: " $response.error.message