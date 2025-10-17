$data = Get-Content -Path "ad_export.json" -Raw | ConvertFrom-Json


$now = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")



$report = @"
================================================================================
                    ACTIVE DIRECTORY AUDIT REPORT
================================================================================
Generated: $($now)
Domain: $($data.domain)
Total Users: $($data.users.Count)

"@


$report | Out-File -FilePath "ad_audit_report.txt"

