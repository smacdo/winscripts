# Gets the weather!
# Author: Scott MacDonald
############################################################################################
# References
#  http://graphical.weather.gov/xml/
#  http://blogs.technet.com/b/heyscriptingguy/archive/2010/11/07/use-powershell-to-retrieve-a-weather-forecast.aspx
#  http://www.4guysfromrolla.com/articles/030205-1.aspx
############################################################################################
Param(
    $zip = 98074,
    $numberOfDays = 3
)

Function Get-Weather
{
    [CmdletBinding()]
    Param(
        [string] $Zip,
        [int] $NumberOfDays)

    return Get-WeatherForecast -Zip $Zip -NumberOfDays $NumberOfDays
}

Function Get-WeatherForecast
{
    [CmdletBinding()]
    Param(
        [string] $Zip,
        [int] $NumberOfDays)

    $location = Find-WeatherLocation -Zip $Zip -SingleResult

    # Query for the weather forecast.
    $URI = "http://www.weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl"
    $Proxy = New-WebServiceProxy -uri $URI -namespace WebServiceProxy

    # Get weather data
    $startDate = Get-Date -UFormat %Y-%m-%d

    $format = "Item24hourly"
    $unit = "e"

    [xml]$weather = $Proxy.NDFDgenByDay($location.lat, $location.lon, $startDate, $NumberOfDays, $unit, $format)

    for ($i = 0; $i -le $numberOfDays - 1; $i ++)
    {
        Write-Verbose ($weather.dwml.data.parameters | Format-List | Out-String)
        Write-Verbose ($weather.dwml.data.parameters.hazards | Format-List | Out-String)
        Write-Verbose ($weather.dwml.data.parameters.weather."weather-conditions" | Format-List | Out-String)

        $p = $weather.dwml.data.parameters

        # TODO: Read dwml.data.parameters.hazards.*  can't see data right now

        New-Object psObject -Property @{
            "Date"              = ((Get-Date).addDays($i)).tostring("MM/dd/yyyy");
            "HighTemp"          = $p.temperature[0].value[$i];
            "LowTemp"           = $p.temperature[1].value[$i];
            "PrecipProbability" = $p."probability-of-precipitation".value[$i];
            "Summary"           = $p.weather."weather-conditions"[$i]."Weather-Summary";
        }
    }
}

Function Find-WeatherLocation
{
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$True, Position=1)]
        [string] $Zip,
        [switch] $SingleResult
    )

    # Collect all the results into an array before deciding how to return it.
    $Results = @()

    # Query NOAA for latitude and longitude of the zip code.
    $URI = "http://www.weather.gov/forecasts/xml/DWMLgen/wsdl/ndfdXML.wsdl"
    $Proxy = New-WebServiceProxy -uri $URI -namespace WebServiceProxy
    
    [xml]$latlon = $Proxy.LatLonListZipCode($Zip)

    # Parse the response and turn it into a powershell object.
    foreach ($l in $latlon)
    {
        $a = $l.dwml.latlonlist -split ","
        $z = New-Object psObject -Property @{
            "lat" = $a[0];
            "lon" = $a[1];
            "zip" = $Zip;
        }

        Write-Verbose ($z | Format-List | Out-String)
        $Results += $z
    }

    # Decide how to return results.
    if ($SingleResult -eq $True)
    {
        Write-Verbose "Returning first result only"
        return $Results[0]
    }
    else
    {
        return $Results
    }
}

#Find-WeatherLocation $zip
Get-WeatherForecast -Zip $zip -NumberOfDays $numberOfDays -Verbose | Format-List | Out-String #| Format-Table -Property date, LowTemp, HighTemp, Summary -AutoSize