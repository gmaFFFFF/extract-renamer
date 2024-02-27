[string] $signPicSuffix = "_sign"

function Get-ExtractCadNum ([Xml] $rosreestrExtractXml)
{
    [string] $cls = Get-ExtractClass ($rosreestrExtractXml)
    switch ($cls){
    'KVZU' {[string] $xpath="/*[local-name() = 'KVZU']/*[local-name() = 'Parcels']/*[local-name() = 'Parcel']/@CadastralNumber"}    
    'Region_Cadastr'{[string] $xpath="//Cadastral_Blocks/Cadastral_Block/@CadastralNumber"}                                      
    'KPT'{[string] $xpath="/*[local-name() = 'KPT']/*[local-name() = 'CadastralBlocks']/*[local-name() = 'CadastralBlock']/@CadastralNumber"}
    'CadastralCostDoc'{[string] $xpath="/*[local-name() = 'CadastralCostDoc']/*[local-name() = 'Object']/@CadastralNumber"}
    'extract_cadastral_plan_territory'{[string] $xpath="/extract_cadastral_plan_territory/cadastral_blocks/cadastral_block/cadastral_number/text()"}
    'Extract'{[string] $xpath="//ObjectRight/ObjectDesc/CadastralNumber/text()" + `
                             "|//NoticeObj/ObjectDetail/CadastralNumber/text()" + `
                             "|//RefusalObj/ObjectDetail/CadastralNumber/text()" + `
                             "|//ExtractObject/ObjectDesc/CadastralNumber/text()"}    
    'Reestr_Extract_Object'{[string] $xpath="/Reestr_Extract_Object/ReestrExtract/ExtractObjectRight/ObjectRight/CadastralNumber/text()" + `
                             "|/Reestr_Extract_Object/ReestrExtract/ExtractObjectRightRefusal/CadastralNumber/text()"}
    'extract_about_zone'{[string] $xpath="/extract_about_zone/zone_territory_coastline_surveying/zones_and_territories/reg_numb_border/text()"}
    {$_ -in 'KPOKS', 'KP_OKS', 'KVOKS'}{[string] $xpath="//*[local-name() = 'Realty']/*[@CadastralNumber]/@CadastralNumber"}
    {$_ -in 'Region_Cadastr_Vidimus_KP','Region_Cadastr_Vidimus_KV', 'KPZU'}{[string] $xpath="//*[local-name() = 'Parcel']/@CadastralNumber"}    
    {$_ -in 'extract_base_params_land', 'extract_base_params_build','extract_base_params_construction', 'extract_about_property_land', 
			'extract_about_property_construction', 'extract_about_property_build', 'extract_cadastral_value_property', 
			'extract_transfer_rights_property', 'extract_base_params_room', 'extract_base_params_under_construction', 
            'extract_about_property_under_construction', 'extract_about_property_room',
            'extract_about_contents_documents_title'} `
            {[string] $xpath="(//object/common_data/cad_number)[1]/text()"}
	default { [string] $xpath="Unknown" }
    
    }
    [string] $cn = (Select-Xml -Xml $rosreestrExtractXml -Xpath $xpath).Node.Value
    
	if (-not $cn){
		
		$xpath="//NoticeObj/ObjectInfo/text()" + `
               "|//RefusalObj/ObjectInfo/text()" + `
			   "|//ExtractObjectRightRefusal/Name/text()" + `
			   "|//content_request/text()"
			   
		[string] $descr = (Select-Xml -Xml $rosreestrExtractXml -Xpath $xpath).Node.Value
		[string] $cn_regex = "\d{1,2}:\d{1,2}:\d{1,7}:\d+"
		
		if ($descr -match $cn_regex) {
			$cn = $matches[0]
		}
	}
	
	return $cn
}

function Get-ExtractDate ([Xml] $rosreestrExtractXml)
{
    [string] $cls = Get-ExtractClass ($rosreestrExtractXml)
    switch ($cls){
    {$_ -in 'extract_base_params_build', 'extract_base_params_land','extract_base_params_construction', 'extract_cadastral_plan_territory', 
				'extract_about_property_land', 'extract_about_property_construction', 'extract_about_property_build', 
				'extract_cadastral_value_property', 'extract_transfer_rights_property', 'extract_base_params_room',
                'extract_base_params_under_construction', 'extract_about_property_under_construction', 'extract_about_property_room',
				'exract_decision_refuse_provide_info', 
				'exract_notice_absence_request_info_11', 'exract_notice_absence_request_info_12', 'exract_notice_absence_request_info_13',
                'extract_about_contents_documents_title',
                'extract_about_zone'}`
        {[string] $xpath="/*/details_request/date_receipt_request_reg_authority_rights/text()"}

    {$_ -in 'Region_Cadastr', 'Region_Cadastr_Vidimus_KP', 'Region_Cadastr_Vidimus_KV','CadastralCostDoc', 'KPOKS', 'KP_OKS', 'KPZU', 'KVZU', 'KPT', 'KVOKS'}`
        {[string] $xpath="//*[local-name() = 'CertificationDoc']/*[local-name() = 'Date']/text()" + `
        "|//*[local-name() = 'Certification_Doc']/*[local-name() = 'Date']/text()"}    
    
    'Reestr_Extract_Object' `
        {[string] $xpath="//*[local-name() = 'ReestrExtract']/@ExtractDate"}
         
    Default `
        {[string] $xpath="//*[local-name() = 'ReestrExtract']/*[local-name() = 'DeclarAttribute']/@ExtractDate"}
    }
    

    [string] $dateStr = (Select-Xml -Xml $rosreestrExtractXml -Xpath $xpath).Node.Value
   
    if(!$dateStr){
        return [datetime]::ParseExact("1990-01-01","yyyy-MM-dd",[Globalization.CultureInfo]::CreateSpecificCulture('ru-RU'))
    }

    $dateStr = $dateStr.Replace('.','-')

    switch -regex ($dateStr){    
    '^\d{1,2}-\d{1,2}-\d\d\d\d$' `
        {[DateTime] $date = [datetime]::ParseExact($dateStr,"dd-MM-yyyy",[Globalization.CultureInfo]::CreateSpecificCulture('ru-RU'))}
    Default `
        {[DateTime] $date = [datetime]::ParseExact($dateStr,"yyyy-MM-dd",[Globalization.CultureInfo]::CreateSpecificCulture('ru-RU'))}
    }


    return $date
}

function Get-ExtractClass ([Xml] $rosreestrExtractXml)
{    
    [string] $xpath = "/*"
    
    [string] $cls = (Select-Xml -Xml $rosreestrExtractXml -Xpath $xpath).Node.LocalName


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
                                 ($fileName+" ЭП.pdf"), `
                                 ($fileName+" ЭП.pdf.sig"), `
                                 ($fileName+$signPicSuffix + ".pdf"), `
                                 ($fileName+$signPicSuffix + ".pdf.sig"), `
                                 ($fileName+".xps"), `
                                 ($fileName+".htm"), `
                                 ($fileName+".html"))
    return $auxFiles
}