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
	Param([String]$Command, [String[]]$Arguments)

	& $Test_HgExists | Out-Null

	Write-Verbose "hg $(((@($Command) + $Arguments) | % { "[$_]" }) -join " ")"

	$result = & hg (@($Command) + $Arguments)
	if ($LastExitCode -ne 0) {
		throw "Error running hg"
	}
	return $result
}.GetNewClosure()

$Test_HgApplicability = {
	Param($Source)

	if ($Source -match "^https://") {
		return 1
	}

	return 0
}.GetNewClosure()

$Get_HgModule = {
	Param($ModuleInfo)

	& $Invoke_HgCommand "clone" $ModuleInfo.Source, $ModuleInfo.Name
}.GetNewClosure()

$Update_HgModule = {
	Param($ModuleInfo)

	& $Invoke_HgCommand "pull"

	$NeedsUpdate = (& $Invoke_HgCommand "log" "-r", "head() & .").length -gt 0

	if ($NeedsUpdate) {
		& $Invoke_HgCommand "update"
	}

	return $NeedsUpdate
}.GetNewClosure()

if (-not ($PsBundle.Providers | ? { $_.ProviderType -eq 'hg' })) {
	Register-PsBundleProvider `
		-ProviderType 'hg' `
		-TestApplicability {
			Param($Source, $Base)
			& $Test_HgApplicability -Source $Source
		}.GetNewClosure() `
		-GetModule {
			Param($ModuleInfo, $Base)
			& $Get_HgModule -ModuleInfo $ModuleInfo
		}.GetNewClosure() `
		-UpdateModule {
			Param($ModuleInfo, $Base)
			& $Update_HgModule -ModuleInfo $ModuleInfo
		}.GetNewClosure()
}
