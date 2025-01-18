#Requires -Modules ActiveDirectory

<#
.SYNOPSIS
    Retrieves BitLocker recovery keys for a computer from Active Directory.

.DESCRIPTION
    This function queries Active Directory to retrieve BitLocker recovery keys
    for a specified computer. It returns all recovery keys sorted by creation date,
    with the most recent key first.

.PARAMETER ComputerName
    The name of the computer for which to retrieve BitLocker recovery keys.
    This parameter accepts pipeline input.

.EXAMPLE
    Get-ADBitlockerRecoveryKey -ComputerName "PC01"
    Retrieves BitLocker recovery keys for computer PC01.

.EXAMPLE
    "PC01", "PC02" | Get-ADBitlockerRecoveryKey
    Retrieves BitLocker recovery keys for multiple computers via pipeline.

.OUTPUTS
    PSCustomObject containing BitLocker recovery keys and their creation dates.

.NOTES
    Requires Active Directory PowerShell module and appropriate permissions to read BitLocker information.
#>
function Get-ADBitlockerRecoveryKey {
    [CmdletBinding()]
    [OutputType([PSCustomObject])]
    param(
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 0
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('CN', 'Name')]
        [string]$ComputerName
    )

    begin {
        # Verify Active Directory module is available
        try {
            Import-Module ActiveDirectory -ErrorAction Stop
            Write-Verbose "Successfully loaded Active Directory module"
        }
        catch {
            $PSCmdlet.ThrowTerminatingError(
                [System.Management.Automation.ErrorRecord]::new(
                    "Failed to load Active Directory module: $_",
                    'ModuleNotFound',
                    [System.Management.Automation.ErrorCategory]::ObjectNotFound,
                    $null
                )
            )
        }
    }

    process {
        try {
            Write-Verbose "Searching for computer: $ComputerName"
            $adComputer = Get-ADComputer -Identity $ComputerName -ErrorAction Stop
            
            Write-Verbose "Found computer. Searching for BitLocker recovery information"
            $recoveryInfo = Get-ADObject -SearchBase $adComputer.DistinguishedName `
                -Filter 'ObjectClass -eq "msFVE-RecoveryInformation"' `
                -Properties msFVE-RecoveryPassword, WhenCreated `
                -ErrorAction Stop |
                Sort-Object -Property WhenCreated -Descending

            if (-not $recoveryInfo) {
                Write-Warning "No BitLocker recovery keys found for computer: $ComputerName"
                return
            }

            Write-Verbose "Found $($recoveryInfo.Count) recovery key(s)"
            foreach ($info in $recoveryInfo) {
                [PSCustomObject]@{
                    ComputerName = $ComputerName
                    RecoveryKey = $info.'msFVE-RecoveryPassword'
                    CreatedDate = $info.WhenCreated
                }
            }
        }
        catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
            Write-Error "Computer '$ComputerName' not found in Active Directory"
        }
        catch {
            Write-Error "Failed to retrieve BitLocker recovery key for '$ComputerName': $_"
        }
    }
}
