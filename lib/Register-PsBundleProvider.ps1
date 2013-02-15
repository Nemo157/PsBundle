Function Register-PsBundleProvider {
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipelineByPropertyName=$true, Mandatory=$true)]
		[String] $ProviderType,

		[Parameter(ValueFromPipelineByPropertyName=$true)]
		[String] $BaseType,

		[Parameter(ValueFromPipelineByPropertyName=$true)]
		[ScriptBlock] $TestApplicability,

		[Parameter(ValueFromPipelineByPropertyName=$true)]
		[ScriptBlock] $GetModule,

		[Parameter(ValueFromPipelineByPropertyName=$true)]
		[ScriptBlock] $UpdateModule
	)

	@('TestApplicability', 'GetModule', 'UpdateModule') | % {
		if (-not (Get-Variable -Name $_ -ValueOnly)) {
			if ($BaseType) {
				Set-Variable -Name $_ -Value {
					Param ($Argument, $Base)
					& $Base[$_] $Argument
				}.GetNewClosure()
			} else {
				throw "Cannot register a primary provider without a $_ function"
			}
		}
	}

	$ProviderInfo = @{
		BaseType = $BaseType
		TestApplicability = $TestApplicability
		GetModule = $GetModule
		UpdateModule = $UpdateModule
	}

	$global:PsBundle.Providers[$ProviderType] = $ProviderInfo
}
