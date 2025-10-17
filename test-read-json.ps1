# Läs in JSON
#$data = Get-Content -Path "ad_export.json" -Raw -Encoding UTF8 | ConvertFrom-Json

# Filtrera ut användare som arbetar på IT avdelningen
#$itDepartmentStaff = $data.users | Where-Object { $_.department -eq "IT" }

#Write-Host $itDepartmentStaff

#$report = ""

#foreach ($user in $itDepartmentStaff) {
#    $report += @"
#Display-name: $($user.displayName)
#Department: $($user.department)
#E-mail: $($user.email) 


#"@
#}

#Write-Host $report
