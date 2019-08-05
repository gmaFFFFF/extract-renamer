. .\RenameTable.ps1

# [string] $path = $MyInvocation.MyCommand.Path | Split-Path -Parent
[string] $path = "C:\Users\user\Desktop\test"
[bool] $isMoveToFolder = $true

[string] $renTableName = $path + "\_renameTable.csv"
[DateTime] $errorDate = [datetime]::ParseExact("1990-01-01","yyyy-MM-dd",[Globalization.CultureInfo]::CreateSpecificCulture('ru-RU'))

if (Test-Path -Path $renTableName){
    if ($isMoveToFolder){
        $extracts =  Import-Csv ($renTableName) -Encoding UTF8 | where {$_.CadNum -and ($_.Date -ne $errorDate -and $_.Date)}
        foreach ($elem in $extracts) {
            If(!(Test-Path $elem.NewFolder)){
                  New-Item -ItemType Directory -Force -Path $elem.NewFolder | Out-Null
            }
            
            if ($elem.Path -ne ($elem.NewFolder + '\' + $elem.NewShortName)){
                Move-Item -LiteralPath $elem.Path -Destination ($elem.NewFolder + '\' + $elem.NewShortName) -Force
                Write-Host ("Move to: " + $elem.NewFolder + '\' + $elem.NewShortName)
            }
        }

    }
    else {
        Import-Csv ($renTableName) -Encoding UTF8 | where {$_.CadNum -and ($_.Date -ne $errorDate -and $_.Date)} | foreach { Rename-Item -LiteralPath $_.Path -NewName $_.NewBigName}
    }
    Remove-Item $renTableName -Force
}
else
{
    [array] $files = ls $path -Filter *.xml -Recurs
    Generate-ExtractRenameTable($files) | Export-Csv -Path ($renTableName) -Encoding UTF8
}
