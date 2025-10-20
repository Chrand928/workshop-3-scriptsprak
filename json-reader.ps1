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

# Collects data and filters it to make a list of inactive users
$inactiveUsers = $data.users | Where-Object {
    ([datetime]$_.lastLogon) -lt (Get-Date).AddDays(-30)
} | Select-Object @{Name = "Username"; Expression = { $_.samAccountName } },
@{Name = "Name"; Expression = { $_.displayName } },
@{Name = "Department"; Expression = { $_.department } },
@{Name = "Last Login"; Expression = { ([datetime]$_.lastLogon).ToString("yyyy-MM-dd") } },
@{Name = "Days Inactive"; Expression = { ((Get-Date) - [datetime]$_.lastLogon).Days } } | 

# Sorts the output showing most inactive users at the top
Sort-Object -Property "Days Inactive" -Descending

# Formats the list to make it look more professional and adds it to the report
$inactiveList = $inactiveUsers | Format-Table -AutoSize | Out-String
$report += $inactiveList

$report += @"
----------------------------------------
USERS PER DEPARTMENT
----------------------------------------
"@

# Groups users by department and formats it to a list with departments in alphabetical order and adds it to the report
$usersByDepartment = $data.users | 
Group-Object -Property department | 
Select-Object Name, Count | 
Sort-Object -Property Name

$departmentList = $usersByDepartment | 
Format-Table -AutoSize | Out-String

$report += $departmentList


$report += @"
----------------------------------------
COMPUTERS PER SITE 
----------------------------------------
"@

# Groups computers per site and formats it to a list with site name alphabetical order and adds it to the report
$computersPerSite = $data.computers | 
Group-Object -Property site | 
Select-Object Name, Count |
Sort-Object -Property site

$computersPerSiteList = $computersPerSite | Format-Table -AutoSize | Out-String
$report += $computersPerSiteList


$report += @"
----------------------------------------
PASSWORD AGE
----------------------------------------
"@

# Collects and sorts data on user password age to add to the report 
$userPasswordAge = $data.users | Select-Object `
@{Label = "Username"; Expression = { $_.samAccountName } }, `
@{Label = "Last Updated"; Expression = { ((Get-Date) - [datetime]$_.passwordLastSet).Days } } | Sort-Object -Property "Last Updated" -Descending


$passwordAgeList = $userPasswordAge | Format-Table -AutoSize | Out-String
$report += $passwordAgeList






# Writes the ad_audit_report.txt file
$report | Out-File -FilePath "ad_audit_report.txt" -Encoding UTF8

# Exports inactiveUsers to CSV
$inactiveUsers | Export-Csv -Path "inactive_users.csv" -NoTypeInformation -Delimiter "," -Encoding UTF8

