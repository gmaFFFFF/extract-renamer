function Get-ExtractCadNum ($rosreestrExtract)
{
    [string] $cls = Get-ExtractClass ($rosreestrExtract)
    switch ($cls){
    'KVZU' {[string] $xpath="/*[local-name() = 'KVZU']/*[local-name() = 'Parcels']/*[local-name() = 'Parcel']/@CadastralNumber"}
    'KVOKS'{[string] $xpath="/*[local-name() = 'KVOKS']/*[local-name() = 'Realty']/*[local-name() = 'Building']/@CadastralNumber"}
    }
    [string] $cn = (Select-Xml $rosreestrExtract.FullName -Xpath $xpath).Node.Value    
    return $cn
}

function Get-ExtractDate ($rosreestrExtract)
{
    [string] $xpath="//*[local-name() = 'ReestrExtract']/*[local-name() = 'DeclarAttribute']/@ExtractDate"
    [string] $dateStr = (Select-Xml $rosreestrExtract.FullName -Xpath $xpath).Node.Value
    [DateTime] $date = [datetime]::ParseExact($dateStr,"dd.MM.yyyy",[Globalization.CultureInfo]::CreateSpecificCulture('ru-RU'))
        
    return $date
}

function Get-ExtractClass ($rosreestrExtract)
{    
    [string] $xpath="(//*)[1]"
    [string] $cls = (Select-Xml -Path $rosreestrExtract.FullName -Xpath $xpath).Node.LocalName 

    return $cls
}


function Get-ExtractAuxFile ($rosreestrExtract)
{
    [string] $fileName = [io.path]::GetFileNameWithoutExtension($rosreestrExtract.Name)
    [string] $folder = $rosreestrExtract.Directory.FullName + "\*"
    [array] $auxFiles = @(Get-ChildItem $folder -Filter ($fileName+"*")  -Include ($fileName+".xml.sig"), ($fileName+".pdf"), ($fileName+".pdf.sig"), ($fileName+".xps"))
    return $auxFiles
}
