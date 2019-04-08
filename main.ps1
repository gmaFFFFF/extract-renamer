. .\RenameTable.ps1

[string] $path = $MyInvocation.MyCommand.Path | Split-Path -Parent
[string] $renTableName = $path + "\renameTable.csv"

if (Test-Path -Path $renTableName){
    Import-Csv ($renTableName) -Encoding UTF8 | Rename-Item
    Remove-Item $renTableName -Force
}
else
{
    [array] $files = ls $path -Filter *.xml -Recurs
    Generate-ExtractRenameTable($files) | Export-Csv -Path ($renTableName) -Encoding UTF8
}
 
