# Applies every migration in supabase/migrations/ in filename order against the
# Supabase Postgres pointed to by $env:DATABASE_URL.
#
# The migrations are idempotent (create table if not exists / create or replace /
# drop ... if exists), so running the full set is safe even if some are already
# applied. psql ON_ERROR_STOP=1 aborts on the first genuine error.
#
# Usage (PowerShell), from the home_tuition_nepal_app folder:
#   $env:DATABASE_URL = "postgresql://postgres.<ref>:<PASSWORD>@aws-0-<region>.pooler.supabase.com:5432/postgres"
#   ./supabase/run_migrations.ps1
#
# Get the connection string from: Supabase Dashboard -> Project Settings ->
# Database -> Connection string -> URI (use the "Session" / direct connection).

$ErrorActionPreference = "Stop"

if (-not $env:DATABASE_URL) {
    Write-Error "DATABASE_URL is not set. See the header of this script for how to set it."
    exit 1
}

$migrationsDir = Join-Path $PSScriptRoot "migrations"
$files = Get-ChildItem -Path $migrationsDir -Filter "*.sql" | Sort-Object Name

Write-Host "Applying $($files.Count) migrations to the database..." -ForegroundColor Cyan

foreach ($file in $files) {
    Write-Host "-> $($file.Name)" -ForegroundColor Yellow
    & psql $env:DATABASE_URL -v ON_ERROR_STOP=1 -f $file.FullName
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Migration failed at $($file.Name). Stopping."
        exit $LASTEXITCODE
    }
}

Write-Host "All migrations applied successfully." -ForegroundColor Green
