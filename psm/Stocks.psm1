#requires -version 5

<#
.SYNOPSIS
Finds the ticker symbol for a stock name.

.DESCRIPTION
Gets a list of potential ticker symbols for a given stock name.

.PARAMETER name
Partial or full name of the stock.

.EXAMPLE
Find-StockSymbol -name Google

.NOTES
Typically the first result in a set of results is the best match.
#>
function Find-StockSymbol {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $name
    )
    Process {
        # Make a web request using the Yahoo! web api to get a list of stock ticker symbols that match the name.
        $name = [System.Web.HttpUtility]::UrlEncode($name)
        $response = Invoke-WebRequest "http://d.yimg.com/autoc.finance.yahoo.com/autoc?query=$name&region=1&lang=en%22"
        $results = $response.Content | ConvertFrom-Json

        # Convert the JSON result into a PowerShell array holding all potential stock ticker symbols.
        $stocks = @()

        foreach ($stock in $results.ResultSet.Result) {
            $stocks += $stock.symbol
        }

        # Return the candidate list.
        $stocks
    }
}

<#
.SYNOPSIS
Get data for a stock ticker symbol.

.DESCRIPTION
Gets data for a stock ticker symbol for the latest trading day using a third party web api.

.PARAMETER symbol
The stock ticker symbol to look up.

.EXAMPLE
Get-Stock -symbol FB

.NOTES
This function will throw an error (ArgumentException) if the symbol could not be found.
#>
function Get-Stock {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory=$true, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [string]
        $symbol
    )
    Process {
        # Make a web api request to get the stock data.
        # Notes on Web API: https://www.alphavantage.co/documentation/
        $symbol = [System.Web.HttpUtility]::UrlEncode($symbol)
        $request = Invoke-WebRequest "https://www.alphavantage.co/query?function=GLOBAL_QUOTE&symbol=$($symbol)&apikey=KPCCCRJVMOGN9L6T" -ErrorAction Stop
        $data = $request.Content | ConvertFrom-Json

        if (-not([bool]($data.PSObject.Properties.name -match 'Global Quote'))) {
            throw [System.ArgumentException]::New("Invalid stock ticker symbol '$($symbol)'")
        }

        # Copy JSON values to a PowerShell object representing the stock data.
        $stock = New-Object -TypeName PSObject -Property @{
            'Symbol'           = $symbol
            'Open'             = [float]::Parse($($data.'Global Quote'.'02. open'), [CultureInfo]::InvariantCulture.NumberFormat)
            'High'             = [float]::Parse($($data.'Global Quote'.'03. high'), [CultureInfo]::InvariantCulture.NumberFormat)
            'Low'              = [float]::Parse($($data.'Global Quote'.'04. low'), [CultureInfo]::InvariantCulture.NumberFormat)
            'Price'            = [float]::Parse($($data.'Global Quote'.'05. price'), [CultureInfo]::InvariantCulture.NumberFormat)
            'Volume'           = [int]::Parse($($data.'Global Quote'.'06. volume'), [CultureInfo]::InvariantCulture.NumberFormat)
            'LatestTradingDay' = $($data.'Global Quote'.'07. latest trading day')
            'PreviousClose'    = [float]::Parse($($data.'Global Quote'.'08. previous close'), [CultureInfo]::InvariantCulture.NumberFormat)
            'Change'           = [float]::Parse($($data.'Global Quote'.'09. change'), [CultureInfo]::InvariantCulture.NumberFormat)
            'ChangePercent'    = $($data.'Global Quote'.'10. change percent')
        }

        # Adjust fields to have natively typed data instead of formatted string output.
        $stock.ChangePercent = [float]::Parse(
            $stock.ChangePercent.Substring(0, $stock.ChangePercent.Length - 1),
            [CultureInfo]::InvariantCulture.NumberFormat)

        $stock.LatestTradingDay = [DateTime]::ParseExact(
            $stock.LatestTradingDay,
            "yyyy-MM-dd",
            $null)

        # Return the stock.
        $stock
    }
}
