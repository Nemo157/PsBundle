Function Install-Bundle {
	[CmdletBinding()]
	Param([switch] $Update)
	$global:PsBundle.Modules.Requested | ? {
		$Update -or ($global:PsBundle.Modules.Installed -notcontains $_)
	} | % {
		$ModuleInfo = $_
		try {
			if ($global:PsBundle.Modules.Installed -contains $ModuleInfo) {
				Write-Host "Updating $($ModuleInfo.Name)"
				if (Update-PsBundleModule $ModuleInfo) {
					Remove-Module $ModuleInfo.Name -Force
					Import-Module $ModuleInfo.Name
				}
			} else {
				Write-Host "Installing $($ModuleInfo.Name)"
				Install-PsBundleModule $ModuleInfo
			}
		} catch {
			"Processing $($ModuleInfo.Name) failed: $_"
		}
	}
}

