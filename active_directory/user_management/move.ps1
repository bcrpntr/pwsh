# Define the search value for filtering users
$searchValue = "$changeme"

# Define the path for the CSV file to log user movements
$csvPath = "C:\path\to\your\log.csv"

# Define destination OU
$destinationOU = "OU=DestinationOU,OU=ParentOU,DC=domain,DC=com"

# Define the list of nested source OUs
$sourceOUs = @(
    "OU=SourceOU1,OU=ParentOU,DC=domain,DC=com",
    "OU=SourceOU2,OU=ParentOU,DC=domain,DC=com",
    "OU=SourceOU3,OU=ParentOU,DC=domain,DC=com",
    "OU=SourceOU4,DC=domain,DC=com"
)

# Create an empty array to store the log
$logEntries = @()

# Function to extract only the OU from the Distinguished Name (DN)
function Get-OUFromDN {
    param (
        [string]$distinguishedName
    )
    # Split the DN by commas and return only the parts that start with "OU="
    $dnParts = $distinguishedName -split ','
    $ouParts = $dnParts -like "OU=*"
    return ($ouParts -join ",")
}

# Loop through each source OU
foreach ($sourceOU in $sourceOUs) {
    # Get all users matching the search value from the current source OU and its nested sub-OUs
    $users = Get-ADUser -Filter {Name -like $searchValue} -SearchBase $sourceOU -SearchScope Subtree

    # Loop through each user and move them to the destination OU
    foreach ($user in $users) {
        $userDN = $user.DistinguishedName
        
        # Extract just the OU from the DN
        $sourceOUOnly = Get-OUFromDN -distinguishedName $userDN
        
        # Add log entry with user name, source OU, and destination OU
        $logEntries += [pscustomobject]@{
            UserName    = $user.Name
            SourceOU    = $sourceOUOnly
            DestinationOU = $destinationOU
        }
        
        # Move the user (simulated with -WhatIf, remove -WhatIf to actually move users)
        Move-ADObject -Identity $userDN -TargetPath $destinationOU # -WhatIf
        Write-Host "Moved user $($user.Name) from $($sourceOUOnly) to $destinationOU"
    }
}

# Export the log to CSV
$logEntries | Export-Csv -Path $csvPath -NoTypeInformation -Append

Write-Host "User movements logged to $csvPath"
