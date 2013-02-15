$Test_GitExists = {
	[CmdletBinding()]
	Param()
	if ($GitExists -eq $null) {
		try {
			& git --version | Out-Null
			$GitExists = $LastExitCode -eq 0
		} catch {
			$GitExists = $false
		}
	}
	if (-not $GitExists) {
		Write-Error "git not found"
	}
	return $GitExists
}.GetNewClosure()

$Invoke_GitCommand = {
	Param([String[]]$Arguments)

	& $Test_GitExists | Out-Null

	Write-Verbose "git $(($Arguments | % { "[$_]" }) -join " ")"

	$result = & git $Arguments
	if ($LastExitCode -ne 0) {
		throw "Error running git"
	}
	return $result
}.GetNewClosure()

$Test_GitApplicability = {
	Param($Source)

	if ($Source -match "^git://") {
		return 5
	}

	if ($Source -match "^.+@.+:.+$") {
		return 2
	}

	if ($Source -match "^https?://") {
		return 1
	}

	return 0
}

$Get_GitModule = {
	Param($ModuleInfo)
	& $Invoke_GitCommand "clone", $ModuleInfo.Source, $ModuleInfo.Name
}.GetNewClosure()

$Update_GitModule = {
	Param($ModuleInfo)

	& $Invoke_GitCommand "fetch"

	$NeedsUpdate = (& $Invoke_GitCommand "log", "HEAD..FETCH_HEAD").length -gt 0

	if ($NeedsUpdate) {
		& $Invoke_GitCommand "fetch"
	}

	return $NeedsUpdate
}.GetNewClosure()

if (-not ($PsBundle.Providers | ? { $_.ProviderType -eq 'git' })) {
	Register-PsBundleProvider `
		-ProviderType 'git' `
		-TestApplicability {
			Param($Source, $Base)
			& $Test_GitApplicability -Source $Source
		}.GetNewClosure() `
		-GetModule {
			Param($ModuleInfo, $Base)
			& $Get_GitModule -ModuleInfo $ModuleInfo
		}.GetNewClosure() `
		-UpdateModule {
			Param($ModuleInfo, $Base)
			& $Update_GitModule -ModuleInfo $ModuleInfo
		}.GetNewClosure()
}
