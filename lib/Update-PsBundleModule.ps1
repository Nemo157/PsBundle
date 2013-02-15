Function Update-PsBundleModule ($ModuleInfo) {
	$Provider = $global:PsBundle.Providers[$ModuleInfo.ProviderType]
	if ($Provider.BaseType) {
		$BaseProvider = $global:PsBundle.Providers[$Provider.BaseType]
	}

	Push-Location (Join-Path $Home "Documents\WindowsPowershell\Modules\$($ModuleInfo.Name)")
	try {
		$Result = & $Provider.UpdateModule $ModuleInfo $BaseProvider
	} finally {
		Pop-Location
	}

	return $Result
}
