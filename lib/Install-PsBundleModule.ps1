Function Install-PsBundleModule ($ModuleInfo) {
	$Provider = $global:PsBundle.Providers[$ModuleInfo.ProviderType]
	if ($Provider.BaseType) {
		$BaseProvider = $global:PsBundle.Providers[$ModuleInfo.BaseType]
	}

	Push-Location (Join-Path $Home "Documents\WindowsPowershell\Modules")
	try {
		& $Provider.GetModule -ModuleInfo $ModuleInfo -Base $BaseProvider
	} finally {
		Pop-Location
	}
	
	if (Get-Module -ListAvailable -Name $ModuleInfo.Name) {
		Import-Module $ModuleInfo.Name
		$global:PsBundle.Modules.Installed += $ModuleInfo
	} else {
		throw "the module does not appear to exist after installation"
	}
}
