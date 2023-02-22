param(
    [string]$ProjectName           = '',
    [string]$ProjectDescription    = '',
    [string]$CommandLineEnv        = 'PowerShell'
)

$AcceptedEnvs = @{
    PowerShell = 'ps';
    Bash = 'bash'
}

function Test-ValidFileName() {
    param([string]$Name)
    
    $InvalidCharIndex = $Name.IndexOfAny([System.IO.Path]::GetInvalidFileNameChars())
    if ($InvalidCharIndex -gt -1) {
        Write-Host "Error: invalid char $Name[$InvalidCharIndex] in name '$Name'"
    }

    return $InvalidCharIndex -eq -1
}

function List-AcceptedEnvs() {
    $EnvString = ''
    foreach($Env in $AcceptedEnvs.Keys) {
        $EnvString += "$Env, "
    }
    $EnvString = $EnvString.TrimEnd(', ')

    Write-Host "Accepted command line environments: $EnvString"
}

function Replace-ProjectName() {
    param(
        [string]$ProjectName,
        [string]$ProjectDescription
    )

    $ForwardSlashScriptRoot = $PSScriptRoot.Replace('\', '/')
    $Sanitized = $ProjectName

    foreach ($SpecialChar in '.', '-', ' ', ',', ';', '!') {
        $SanitizedProjectName = $ProjectName.Replace($SpecialChar, '_')
    }
    
    # CMakeLists.txt

    $CMakeListsTxtContents = (Get-Content -Path 'CMakeLists.txt').
        Replace('<Project Name>', $ProjectName).
        Replace('<project_name>', $Sanitized.ToLower()).
        Replace('<PROJECT_NAME>', $Sanitized.ToUpper()).
        Replace('<Project Description>', $ProjectDescription)
    
    Set-Content -Path 'CMakeLists.txt' -Value $CMakeListsTxtContents

    # .clangd

    $ClangdContents = (Get-Content -Path '.clangd').
        Replace('<project_directory>', $ForwardSlashScriptRoot)

    Set-Content -Path '.clangd' -Value $ClangdContents

    # project_name/main.hpp

    $MainHppContents = (Get-Content -Path 'project_name/main.hpp').
        Replace('<PROJECT_NAME>', $Sanitized.ToUpper())

    Set-Content -Path 'project_name/main.hpp' -Value $MainHppContents

    # project_name/

    Rename-Item -Path 'project_name' -NewName $Sanitized.ToLower()

    # README.md

    $ReadmeMdContents = `
@"
$ProjectName
$('=' * $ProjectName.Length)


"@

    Set-Content -Path 'README.md' -Value $ReadmeMdContents
}

function Copy-TasksJSon() {
    param([string]$TasksJsonName)

    Copy-Item -Path $TasksJsonName -Destination '.vscode/tasks.json'
}

function Delete-DummyFiles() {
    $DummyFiles = @(
        'build/dummy',
        'external/include/dummy',
        'external/lib/dummy'
    )
    foreach ($f in $DummyFiles) {
        Remove-Item -Path $f -Force
    }
}

function Reset-GitRepo() {
    Remove-Item -Path ".git" -Force -Recurse
    git init
}

function Delete-Self() {
    Remove-Item -Path $PSCommandPath -Force
}

##
## SETUP
##

if ($AcceptedEnvs.Keys -inotcontains $CommandLineEnv) {
    Write-Host "Error: unknown command line environment '$CommandLineEnv'"
    List-AcceptedEnvs
}

$TasksJson = '.vscode/tasks_{0}.json' -f $AcceptedEnvs[$CommandLineEnv]

$ProjectName = $ProjectName.Trim()
while (-not ($ProjectName -and (Test-ValidFileName $ProjectName))) {
    $ProjectName = Read-Host -Prompt 'Please provide a valid project name'
    $ProjectName = $ProjectName.Trim()
}

$Placeholder = "=" * $ProjectName.Length

Write-Host @"
DEPLOYING BOILERPLATE FOR NEW C++ PROJECT < $ProjectName >
============================================$Placeholder==

This script will:
- Replace all occurrences of 'project_name' (and variants thereof) within the
  folder structure with '$ProjectName'
- Create '.vscode/tasks.json' with the same contents as '$TasksJson'
- Delete dummy files
- Delete the Git repository and initialize a new one

The script will then self-delete.
"@

$Proceed = Read-Host -Prompt 'Do you want to proceed? [y/N]'

if (-not $Proceed.StartsWith('y', "InvariantCultureIgnoreCase")) {
    exit 1
}

$OriginalLocation = Get-Location
Set-Location $PSScriptRoot

Replace-ProjectName $ProjectName $ProjectDescription
Copy-TasksJSon $TasksJSon
Delete-DummyFiles
Reset-GitRepo
Delete-Self

Set-Location $OriginalLocation