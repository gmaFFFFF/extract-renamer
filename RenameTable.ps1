. .\ExtractReader.ps1


function Generate-ExtractRenameTable($rosreestrExtracts)
{
    [array]$RenameTable = @()
    foreach ($extract in $rosreestrExtracts)
    {   
                       
        [string] $extrClass = Get-ExtractClass($extract)
        [DateTime] $extrDate = Get-ExtractDate($extract)
        [string] $extrCadNum = (Get-ExtractCadNum($extract))
                
        [string] $fileName = $extract.Name
        [string] $extractName = [io.path]::GetFileNameWithoutExtension($fileName)
     
        [string] $newName = "{2}_{1}_{0}" -f ($extrDate.ToString("yyyy-MM-dd")),$extrCadNum.Replace(":","-"),$extrClass
        
        [array] $allFile = Get-ExtractAuxFile($extract)
        $allFile += $extract

        foreach($file in $allFile)
        {
            $rec = [PSCustomObject]@{
                    Path=$file.FullName
                    NewName = $file.Name.Replace($extractName,$newName)
                    CadNum = $extrCadNum
                    ClassExtr = $extrClass
                    Date = $extrDate
            }
            $RenameTable += $rec
        }
    }
    return $RenameTable
}


