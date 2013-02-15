if (-not ($PsBundle.Providers | ? { $_.ProviderType -eq 'github' })) {
	Register-PsBundleProvider `
		-ProviderType 'github' `
		-BaseType 'git' `
		-TestApplicability {
			Param($Source, $Base)
			if ($Source -match '^\w*/\w*$') {
				return 1
			}
			return 0
		} `
		-GetModule {
			Param($ModuleInfo, $Base)
			$ModuleInfo = $ModuleInfo.Clone()
			$ModuleInfo.Source = 'https://github.com/' + $ModuleInfo.Source
			& $Base.GetModule -ModuleInfo $ModuleInfo
		}
}
