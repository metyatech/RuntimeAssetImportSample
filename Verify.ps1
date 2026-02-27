[CmdletBinding()]
param(
    [string]$TestFilter = 'RuntimeAssetImport',

    [ValidateSet('DebugGame', 'Development', 'Shipping')]
    [string]$Configuration = 'Development',

    [ValidateSet('Win64')]
    [string]$Platform = 'Win64',

    [switch]$SkipFormat,
    [switch]$SkipBuild,
    [switch]$SkipTests,

    [switch]$EnableNullRHI,
    [switch]$DisableRenderOffscreen,
    [switch]$DisableUnattended,
    [switch]$DisableNoSound
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

function Write-Info([string]$Message) { Write-Host "[INFO] $Message" -ForegroundColor Cyan }
function Write-Warn([string]$Message) { Write-Host "[WARN] $Message" -ForegroundColor Yellow }
function Write-Err([string]$Message) { Write-Host "[ERROR] $Message" -ForegroundColor Red }

function Invoke-ExternalCommand {
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,
        [string[]]$ArgumentList = @(),
        [string]$WorkingDirectory
    )
    $wd = if ([string]::IsNullOrWhiteSpace($WorkingDirectory)) { (Get-Location).Path } else { $WorkingDirectory }
    $proc = Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -WorkingDirectory $wd -NoNewWindow -PassThru -Wait
    if ($proc.ExitCode -ne 0) {
        throw "Command failed (ExitCode=$($proc.ExitCode)): $FilePath $($ArgumentList -join ' ')"
    }
}

function Resolve-ToolPath {
    param([string]$Name, [string]$EngineRoot)
    $cmd = Get-Command $Name -ErrorAction SilentlyContinue
    if ($null -ne $cmd -and $null -ne $cmd.Path) { return $cmd.Path }
    $candidates = @(
        (Join-Path $EngineRoot 'Engine\Extras\ThirdPartyNotUE\LLVM\Win64\bin'),
        (Join-Path $EngineRoot 'Engine\Binaries\ThirdParty\LLVM\Win64\bin')
    ) | Where-Object { Test-Path -LiteralPath $_ }
    foreach ($dir in $candidates) {
        $exe = Join-Path $dir ($Name + '.exe')
        if (Test-Path -LiteralPath $exe) { return $exe }
    }
    throw "Required command not found: $Name"
}

try {
    $repoRoot = (Resolve-Path $PSScriptRoot).Path
    Set-Location $repoRoot

    $uprojectPath = Join-Path $repoRoot 'RuntimeAssetImportSample.uproject'
    if (-not (Test-Path -LiteralPath $uprojectPath)) {
        throw "RuntimeAssetImportSample.uproject not found at: $uprojectPath"
    }

    $json = Get-Content -LiteralPath $uprojectPath -Raw | ConvertFrom-Json
    $ueVersion = [string]$json.EngineAssociation

    $resolverScript = Join-Path $repoRoot 'UnrealBuildRunTestScript\Get-UEInstallPath.ps1'
    $engineRoot = (& powershell -NoProfile -ExecutionPolicy Bypass -File $resolverScript -Version $ueVersion).Trim()
    if ([string]::IsNullOrWhiteSpace($engineRoot) -or -not (Test-Path -LiteralPath $engineRoot)) {
        throw "UE engine root not found for version: $ueVersion"
    }

    Write-Info "Repo: $repoRoot"
    Write-Info "UE: $ueVersion ($engineRoot)"

    if (-not $SkipFormat) {
        Write-Info 'Running C++ format check (clang-format --dry-run --Werror) ...'
        $clangFormat = Resolve-ToolPath -Name 'clang-format' -EngineRoot $engineRoot
        $pluginSrcDir = Join-Path $repoRoot 'Plugins\RuntimeAssetImport\Source'
        if (Test-Path -LiteralPath $pluginSrcDir) {
            $formatExtensions = @('.h', '.hh', '.hpp', '.cpp', '.cc', '.cxx')
            $formatFiles = & git -C (Join-Path $repoRoot 'Plugins\RuntimeAssetImport') ls-files -- 'Source'
            foreach ($file in ($formatFiles | Where-Object { $formatExtensions -contains [IO.Path]::GetExtension($_) })) {
                $fullPath = Join-Path (Join-Path $repoRoot 'Plugins\RuntimeAssetImport') $file
                & $clangFormat --dry-run --Werror --style=file $fullPath
                if ($LASTEXITCODE -ne 0) { throw "clang-format check failed: $file" }
            }
        }
        else {
            Write-Warn "Plugin source not found at $pluginSrcDir, skipping format check."
        }
    }

    if (-not $SkipBuild -or -not $SkipTests) {
        $testScript = Join-Path $repoRoot 'UnrealBuildRunTestScript\BuildAndTest.ps1'
        $argsList = @(
            '-NoProfile', '-ExecutionPolicy', 'Bypass',
            '-File', $testScript,
            '-Platform', $Platform,
            '-Configuration', $Configuration,
            '-TestFilter', $TestFilter
        )
        if (-not $EnableNullRHI) { $argsList += '-DisableNullRHI' }
        if ($DisableRenderOffscreen) { $argsList += '-DisableRenderOffscreen' }
        if ($DisableUnattended) { $argsList += '-DisableUnattended' }
        if ($DisableNoSound) { $argsList += '-DisableNoSound' }

        if ($SkipBuild) { $argsList += '-SkipBuild' }
        if ($SkipTests) { $argsList += '-SkipTests' }

        Write-Info "Building and running tests: $TestFilter"
        Invoke-ExternalCommand -FilePath 'powershell' -ArgumentList $argsList -WorkingDirectory $repoRoot
    }

    Write-Info 'VERIFY PASSED'
    exit 0
}
catch {
    Write-Err $_.Exception.Message
    exit 1
}
