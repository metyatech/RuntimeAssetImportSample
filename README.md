# RuntimeAssetImportSample

Minimal UE5.4 host project for building and testing [RuntimeAssetImportPlugin](https://github.com/metyatech/RuntimeAssetImportPlugin) in CI.

This project is not intended for end users. It serves as the test host for plugin automation tests.

## Setup

```bash
git clone --recursive https://github.com/metyatech/RuntimeAssetImportSample.git
```

## Running tests locally

```powershell
.\Verify.ps1 -TestFilter "RuntimeAssetImport"
```

## CI

Uses GitHub Actions self-hosted runner (Windows). Triggered on push and pull_request.
