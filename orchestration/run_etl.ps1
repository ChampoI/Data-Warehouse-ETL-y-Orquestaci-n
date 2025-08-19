param(
  [string]$PythonExe = "python"
)

Write-Host "Installing Python requirements..."
& $PythonExe -m pip install -r (Join-Path $PSScriptRoot "..\etl\requirements.txt")

Write-Host "Running ETL ..."
& $PythonExe (Join-Path $PSScriptRoot "..\etl\generate_and_load.py")
