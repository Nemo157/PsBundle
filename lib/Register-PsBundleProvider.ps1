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
		$MethodName = $_
		if (-not (Get-Variable -Name $MethodName -ValueOnly)) {
			if ($BaseType) {
				Set-Variable -Name $MethodName -Value {
					Param ($Argument, $Base)
					& $Base[$MethodName] $Argument
				}.GetNewClosure()
			} else {
				throw "Cannot register a primary provider without a $MethodName function"
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
