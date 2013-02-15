Function Find-ProviderType {
	Param($Source)

	$Applicabilities = @{
	}

	$global:PsBundle.Providers.Keys | % {
		[String]$Applicability = & $global:PsBundle.Providers[$_].TestApplicability -Source $Source
		if ($Applicabilities.Keys -notcontains $Applicability) {
			$Applicabilities[$Applicability] = @()
		}
		$Applicabilities[$Applicability] += $_
	}

	Write-Verbose "ProviderType Applicabilities:"
	Write-Verbose ($Applicabilities | Out-String)

	$Best = $Applicabilities.Keys | Sort-Object -Descending | Select-Object -First 1

	if ($Best -gt 0) {
		if ($Applicabilities[$Best].Length -eq 1) {
			return $Applicabilities[$Best][0]
		} else {
			throw "multiple potential ProviderTypes: $($Applicabilities[$Best] -join ', ')"
		}
	} else {
		throw "no potential ProviderTypes found"
	}
}

