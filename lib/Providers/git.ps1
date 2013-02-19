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
		throw "git not found"
	}
}.GetNewClosure()

$Invoke_GitCommand = {
	[CmdletBinding()]
	Param(
		[Parameter(ValueFromRemainingArguments = $true)]
		[String[]] $Arguments
	)

	& $Test_GitExists | Out-Null

	Write-Verbose "git $(($Arguments | % { "[$_]" }) -join " ")"

	$result = & git $Arguments
	if ($LastExitCode -ne 0) {
		throw "Error running git"
	}
	return $result
}.GetNewClosure()

$Test_GitApplicability = {
	[CmdletBinding()]
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
	[CmdletBinding()]
	Param($ModuleInfo)
	& $Invoke_GitCommand "clone" $ModuleInfo.Source $ModuleInfo.Name
}.GetNewClosure()

$Update_GitModule = {
	[CmdletBinding()]
	Param($ModuleInfo)

	(& $Invoke_GitCommand "fetch" $ModuleInfo.Source "master:" "2>&1") | Write-Verbose

	$LogOutput = (& $Invoke_GitCommand "log" "HEAD..FETCH_HEAD")
	$LogOutput | Write-Verbose
	$NeedsUpdate = ($LogOutput.length -gt 0)

	if ($NeedsUpdate) {
		Write-Host "Update for $($ModuleInfo.Name) found"

		& $Invoke_GitCommand "update-index" "-q" "--refresh" | Out-Null
		$Changed = (& $Invoke_GitCommand "diff-index" "--name-only" "HEAD" "--").Length -gt 0

		if ($Changed) {
			throw "Not updating as the working tree contains changes"
		}

		(& $Invoke_GitCommand "merge" "FETCH_HEAD" "--ff-only") | Write-Verbose
	}

	return $NeedsUpdate
}.GetNewClosure()

if (-not ($PsBundle.Providers | ? { $_.ProviderType -eq 'git' })) {
	Register-PsBundleProvider `
		-ProviderType 'git' `
		-TestApplicability {
			[CmdletBinding()]
			Param($Source, $Base)
			& $Test_GitApplicability -Source $Source
		}.GetNewClosure() `
		-GetModule {
			[CmdletBinding()]
			Param($ModuleInfo, $Base)
			& $Get_GitModule -ModuleInfo $ModuleInfo
		}.GetNewClosure() `
		-UpdateModule {
			[CmdletBinding()]
			Param($ModuleInfo, $Base)
			return (& $Update_GitModule -ModuleInfo $ModuleInfo)
		}.GetNewClosure()
}
