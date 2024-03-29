﻿. .\ExtractReader.ps1


function Generate-ExtractRenameTable($rosreestrExtracts)
{
    [array]$RenameTable = @()
    foreach ($extract in $rosreestrExtracts)
    {   
        Write-Host ("Processing: " + $extract.FullName)
        
        # Ручная загрузка Xml файла, чтобы обойти ограничение MaxCharactersInDocument = 536870912 (0.5gb)
        [Xml] $extractXml = New-Object Xml
        $extractXml.Load($extract.FullName)

                       
        [string] $extrClass = Get-ExtractClass($extractXml)
        [DateTime] $extrDate = Get-ExtractDate($extractXml)
        [string] $extrCadNum = Get-ExtractCadNum($extractXml)
                
        [string] $fileName = $extract.Name
        [string] $extractName = [io.path]::GetFileNameWithoutExtension($fileName)
     
        [string] $newBigName = "{0}_{1}_{2}" -f ($extrCadNum.Replace(":"," "), $extrDate.ToString("yyyy-MM-dd"), $extrClass)        
        [string] $newShortName = "{0}_{1}" -f ($extrDate.ToString("yyyy-MM-dd"), $extrClass)

        if ($extract.Directory.Name -eq $extrCadNum.Replace(":"," ")){
            [string] $newFolder = $extract.Directory.FullName
        }
        else{
            [string] $newFolder = $extract.Directory.FullName + '\' + $extrCadNum.Replace(":"," ")
        }
        
        [array] $allFile = Get-ExtractAuxFile($extract)
        $allFile += $extract

        foreach($file in $allFile)
        {

            $rec = [PSCustomObject]@{
                    Path=$file.FullName
                    NewBigName = $file.Name.Replace($extractName,$newBigName).Replace(" ЭП",$signPicSuffix)
                    NewShortName = $file.Name.Replace($extractName,$newShortName).Replace(" ЭП",$signPicSuffix)
                    NewFolder = $newFolder
                    CadNum = $extrCadNum
                    ClassExtr = $extrClass
                    Date = $extrDate
            }
            $RenameTable += $rec
        }
    }
    return $RenameTable
}

