Function Register-Module {
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipelineByPropertyName=$true)]
		[String] $Name,

		[Parameter(ValueFromPipelineByPropertyName=$true)]
		[String] $ProviderType,

		[Parameter(ValueFromPipelineByPropertyName=$true, Mandatory=$true, Position=0)]
		[String] $Source
	)

	Write-Verbose "Register-Module -Name [$Name] -ProviderType [$ProviderType] -Source [$Source]"

	if ($ProviderType) {
		Write-Verbose "Provider Type [$ProviderType] supplied"
		if ($global:PsBundle.Providers.Keys -notcontains $ProviderType) {
			throw "$ProviderType is an unknown provider type"
		}
	} else {
		try {
			Write-Verbose "Finding provider type for [$Source]"
			$ProviderType = Find-ProviderType -Source $Source
			Write-Verbose "Found provider type [$ProviderType] for [$Source]"
		} catch {
			throw "Cannot automatically determine a provider type for $Source because $_. Try specifying ProviderType argument."
		}
	}

	if (-not $Name) {
		$Name = Guess-Name $Source
		if (-not $Name) {
			throw "Cannot automatically determine a module name for $Source. Try specifying Name argument."
		}
	}

	$ModuleInfo = @{
		'Name' = $Name
		'ProviderType' = $ProviderType
		'Source' = $Source
	}

	$global:PsBundle.Modules.Requested += $ModuleInfo

	if (Get-Module -ListAvailable -Name $Name) {
		Import-Module $Name
		$global:PsBundle.Modules.Installed += $ModuleInfo
	}
}

