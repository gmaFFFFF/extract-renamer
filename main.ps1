. .\RenameTable.ps1

# [string] $path = $MyInvocation.MyCommand.Path | Split-Path -Parent
[string] $path = "C:\Users\user\Desktop\test"
[bool] $isMoveToFolder = $true

[string] $renTableName = $path + "\renameTable.csv"

if (Test-Path -Path $renTableName){
    if ($isMoveToFolder){
        $extracts =  Import-Csv ($renTableName) -Encoding UTF8
        foreach ($elem in $extracts) {
            If(!(Test-Path $elem.NewFolder)){
                  New-Item -ItemType Directory -Force -Path $elem.NewFolder | Out-Null
            }

            Move-Item -LiteralPath $elem.Path -Destination ($elem.NewFolder + '\' + $elem.NewShortName)
        }

    }
    else {
        Import-Csv ($renTableName) -Encoding UTF8 | foreach { Rename-Item -LiteralPath $_.Path -NewName $_.NewBigName}
    }
    Remove-Item $renTableName -Force
}
else
{
    [array] $files = ls $path -Filter *.xml -Recurs
    Generate-ExtractRenameTable($files) | Export-Csv -Path ($renTableName) -Encoding UTF8
}
 
