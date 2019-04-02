. .\RenameTable.ps1

[string] $path = "\\msk-gis01\MSSQLSERVER\Doc\RosreestrInbox\Быстрые выписки\kbr20171204"
[string] $renTableName = "\renameTable.csv"


[array] $files = ls $path -Filter *.xml #-Recurs
Generate-ExtractRenameTable($files) | Export-Csv -Path ($path + $renTableName) -Encoding UTF8

# Import-Csv ($path + $renTableName) -Encoding UTF8 | Rename-Item