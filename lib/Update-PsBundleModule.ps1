Function Update-PsBundleModule ($ModuleInfo) {
	$Provider = $global:PsBundle.Providers[$ModuleInfo.ProviderType]
	if ($Provider.BaseType) {
		$BaseProvider = $global:PsBundle.Providers[$ModuleInfo.BaseType]
	}

	Push-Location (Join-Path $Home "Documents\WindowsPowershell\Modules\$($ModuleInfo.Name)")
	try {
		& $Provider.UpdateModule -ModuleInfo $ModuleInfo -Base $BaseProvider
	} finally {
		Pop-Location
	}
}
