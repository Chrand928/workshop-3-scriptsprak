$data = Get-Content -Path "ad_export.json" -Raw | ConvertFrom-Json

# Collects realtime and date and adds formatting to make it pretty
$now = (Get-Date).ToString("yyyy-MM-dd HH:mm:ss")

# Collects export_date from the json file and formats it
$formattedExportDate = [datetime]::Parse($data.export_date).ToString("yyyy-MM-dd HH:mm:ss")

# Start of the report
$report = @"
========================================
       ACTIVE DIRECTORY RAPPORT
========================================
Generated: $($now)
Domain: $($data.domain)
Export Date: $formattedExportDate

----------------------------------------
INACTIVE USERS (No login >30 days)
----------------------------------------
"@

# Collects data and filters and formats it to make a list of inactive users
$inactiveUsers = $data.users | Where-Object {
    ([datetime]$_.lastLogon) -lt (Get-Date).AddDays(-30)
} | Select-Object @{Name = "Username"; Expression = { $_.samAccountName } },
@{Name = "Name"; Expression = { $_.displayName } },
@{Name = "Department"; Expression = { $_.department } },
@{Name = "Last Login"; Expression = { ([datetime]$_.lastLogon).ToString("yyyy-MM-dd") } },
@{Name = "Days Inactive"; Expression = { ((Get-Date) - [datetime]$_.lastLogon).Days } } | 

# Sorts the output showing most inactive users at the top
Sort-Object -Property "Days Inactive" -Descending

$inactiveList = $inactiveUsers | Format-Table -AutoSize | Out-String
$report += $inactiveList






$report | Out-File -FilePath "ad_audit_report.txt" -Encoding UTF8
