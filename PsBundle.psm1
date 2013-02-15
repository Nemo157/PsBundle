##
##      Powershell interactive session module management
##      URL: https://github.com/Nemo157/psbundle
##      Based on Vundle (https://github.com/gmarik/vundle)
##

$global:PsBundle = @{
	Providers = @{}
	Modules = @{
		Requested = @()
		Installed = @()
	}
}

$BasePath = Split-Path $MyInvocation.MyCommand.Definition

@(
	'lib\Find-ProviderType.ps1'
	'lib\Install-Bundle.ps1'
	'lib\Install-PsBundleModule.ps1'
	'lib\Register-Module.ps1'
	'lib\Register-PsBundleProvider.ps1'
	'lib\Update-Bundle.ps1'
	'lib\Update-PsBundleModule.ps1'
) | % { . (Join-Path $BasePath $_) }

@(
	'lib\Providers\git.ps1'
	'lib\Providers\hg.ps1'
	'lib\Providers\github.ps1'
) | % { & (Join-Path $BasePath $_) }

$PsBundleModuleInfo = @{
	Name = 'PsBundle'
	ProviderType = 'github'
	Source = 'Nemo157/PsBundle'
}

$global:PsBundle.Modules.Requested += $PsBundleModuleInfo
$global:PsBundle.Modules.Installed += $PsBundleModuleInfo
