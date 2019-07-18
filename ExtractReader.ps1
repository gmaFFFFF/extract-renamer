function Get-ExtractCadNum ($rosreestrExtract)
{
    [string] $cls = Get-ExtractClass ($rosreestrExtract)
    switch ($cls){
    'KVZU' {[string] $xpath="/*[local-name() = 'KVZU']/*[local-name() = 'Parcels']/*[local-name() = 'Parcel']/@CadastralNumber"}
    'KVOKS'{[string] $xpath="/*[local-name() = 'KVOKS']/*[local-name() = 'Realty']/*[@CadastralNumber]/@CadastralNumber"}
    'KPOKS'{[string] $xpath="/*[local-name() = 'KPOKS']/*[local-name() = 'Realty']/*[@CadastralNumber]/@CadastralNumber"}
    {$_ -in 'Region_Cadastr_Vidimus_KP','Region_Cadastr_Vidimus_KV', 'KPZU'}{[string] $xpath="//*[local-name() = 'Parcel']/@CadastralNumber"}    
    'Region_Cadastr'{[string] $xpath="/Region_Cadastr/Package/Cadastral_Blocks/Cadastral_Block/@CadastralNumber"}
    'KPT'{[string] $xpath="/*[local-name() = 'KPT']/*[local-name() = 'CadastralBlocks']/*[local-name() = 'CadastralBlock']/@CadastralNumber"}
    'CadastralCostDoc'{[string] $xpath="/*[local-name() = 'CadastralCostDoc']/*[local-name() = 'Object']/@CadastralNumber"}
    'extract_cadastral_plan_territory'{[string] $xpath="/extract_cadastral_plan_territory/cadastral_blocks/cadastral_block/cadastral_number/text()"}
    'extract_base_params_land'{[string] $xpath="/extract_base_params_land/land_record/object/common_data/cad_number/text()"}
    'extract_base_params_build'{[string] $xpath="/extract_base_params_build/build_record/object/common_data/cad_number/text()"}    
    'Extract'{[string] $xpath="/Extract/ReestrExtract/ExtractObjectRight/ExtractObject/ObjectRight/ObjectDesc/CadastralNumber/text()"}    
    'Reestr_Extract_Object'{[string] $xpath="/Reestr_Extract_Object/ReestrExtract/ExtractObjectRight/ObjectRight/CadastralNumber/text()|/Reestr_Extract_Object/ReestrExtract/ExtractObjectRightRefusal/CadastralNumber/text()"}
    }
    [string] $cn = (Select-Xml -LiteralPath $rosreestrExtract.FullName -Xpath $xpath).Node.Value    
    return $cn
}

function Get-ExtractDate ($rosreestrExtract)
{
    [string] $cls = Get-ExtractClass ($rosreestrExtract)
    switch ($cls){    
    {$_ -in 'extract_base_params_land', 'extract_base_params_build', 'extract_cadastral_plan_territory'}`
        {[string] $xpath="/*/details_statement/group_top_requisites/date_formation/text()"}
    {$_ -in 'KPT', 'CadastralCostDoc', 'KPZU'}`
        {[string] $xpath="//*[local-name() = 'CertificationDoc']/*[local-name() = 'Date']/text()"}    
    {$_ -in 'Region_Cadastr_Vidimus_KP', 'Region_Cadastr_Vidimus_KV','Region_Cadastr'}`
        {[string] $xpath="//*[local-name() = 'Certification_Doc']/*[local-name() = 'Date']/text()"}    
    Default `
        {[string] $xpath="//*[local-name() = 'ReestrExtract']/*[local-name() = 'DeclarAttribute']/@ExtractDate"}
    }
    
    try
    {
        [string] $dateStr = (Select-Xml -LiteralPath $rosreestrExtract.FullName -Xpath $xpath).Node.Value
    }
    catch [system.exception]
    {
        Write-Host "Ошибка при обработке файла " $rosreestrExtract
        Write-Host "Не найдена дата документа"
        $dateStr = "1990-01-01"
    }

    switch ($cls){
    {$_ -in 'extract_cadastral_plan_territory', 'extract_base_params_land', `
            'KPT', 'KPZU', 'extract_base_params_build', 'CadastralCostDoc', `
            'Region_Cadastr', 'Region_Cadastr_Vidimus_KP', 'Region_Cadastr_Vidimus_KV'} `
        {[DateTime] $date = [datetime]::ParseExact($dateStr,"yyyy-MM-dd",[Globalization.CultureInfo]::CreateSpecificCulture('ru-RU'))}
    'Extract' `
        {[DateTime] $date = [datetime]::ParseExact($dateStr,"dd-MM-yyyy",[Globalization.CultureInfo]::CreateSpecificCulture('ru-RU'))}
    Default `
        {[DateTime] $date = [datetime]::ParseExact($dateStr,"dd.MM.yyyy",[Globalization.CultureInfo]::CreateSpecificCulture('ru-RU'))}
    }


    return $date
}

function Get-ExtractClass ($rosreestrExtract)
{    
    [string] $xpath = "/*"
    
    [string] $cls = (Select-Xml -LiteralPath $rosreestrExtract.FullName -Xpath $xpath).Node.LocalName


    return $cls
}


function Get-ExtractAuxFile ($rosreestrExtract)
{
    [string] $fileName = [io.path]::GetFileNameWithoutExtension($rosreestrExtract.Name)
    $fileName = [Management.Automation.WildcardPattern]::Escape($fileName)
    [string] $folder = [Management.Automation.WildcardPattern]::Escape($rosreestrExtract.Directory.FullName) + "\*"

    [array] $auxFiles = @(Get-ChildItem -Path $folder `
                        -Include ($fileName+".xml.original.sig"), `
                                 ($fileName+".xml.original"), `
                                 ($fileName+".xml.sig"), `
                                 ($fileName+".pdf"), `
                                 ($fileName+".pdf.sig"), `
                                 ($fileName+".xps"), `
                                 ($fileName+".htm"), `
                                 ($fileName+".html"))
    return $auxFiles
}
