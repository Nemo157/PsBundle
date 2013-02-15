$Test_HgExists = {
	[CmdletBinding()]
	Param()
	if ($HgExists -eq $null) {
		try {
			& hg --version | Out-Null
			$HgExists = $LastExitCode -eq 0
		} catch {
			$HgExists = $false
		}
	}
	if (-not $HgExists) {
		Write-Error "hg not found"
	}
	return $HgExists
}.GetNewClosure()

$Invoke_HgCommand = {
	[CmdletBinding()]
	Param([String]$Command, [String[]]$Arguments)

	& $Test_HgExists | Out-Null

	Write-Verbose "hg $(((@($Command) + $Arguments) | % { "[$_]" }) -join " ")"

	$result = (& hg (@($Command) + $Arguments))
	if ($LastExitCode -ne 0) {
		throw "Error running hg"
	}
	return $result
}.GetNewClosure()

$Test_HgApplicability = {
	[CmdletBinding()]
	Param($Source)

	if ($Source -match "^https://") {
		return 1
	}

	return 0
}.GetNewClosure()

$Get_HgModule = {
	[CmdletBinding()]
	Param($ModuleInfo)

	& $Invoke_HgCommand "clone" $ModuleInfo.Source, $ModuleInfo.Name
}.GetNewClosure()

$Update_HgModule = {
	[CmdletBinding()]
	Param($ModuleInfo)

	(& $Invoke_HgCommand "pull") | Write-Verbose

	$LogOutput = (& $Invoke_HgCommand "log" "-r", "head() & .")
	$LogOutput | Write-Verbose
	$NeedsUpdate = ($LogOutput.length -eq 0)

	if ($NeedsUpdate) {
		Write-Host "Update for $($ModuleInfo.Name) found"
		(& $Invoke_HgCommand "update") | Write-Verbose
	}

	return $NeedsUpdate
}.GetNewClosure()

if (-not ($PsBundle.Providers | ? { $_.ProviderType -eq 'hg' })) {
	Register-PsBundleProvider `
		-ProviderType 'hg' `
		-TestApplicability {
			[CmdletBinding()]
			Param($Source, $Base)
			& $Test_HgApplicability -Source $Source
		}.GetNewClosure() `
		-GetModule {
			[CmdletBinding()]
			Param($ModuleInfo, $Base)
			& $Get_HgModule -ModuleInfo $ModuleInfo
		}.GetNewClosure() `
		-UpdateModule {
			[CmdletBinding()]
			Param($ModuleInfo, $Base)
			return (& $Update_HgModule -ModuleInfo $ModuleInfo)
		}.GetNewClosure()
}
