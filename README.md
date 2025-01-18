# PS-Tools

A collection of PowerShell tools for various system administration and management tasks.

## Table of Contents
- [Requirements](#requirements)
- [Installation](#installation)
- [Available Tools](#available-tools)
  - [Get-ADBitlockerRecoveryKey](#get-adbitlockerrecoverykey)

## Requirements

- Windows PowerShell 5.1 or PowerShell Core 7.x
- Required PowerShell Modules:
  - ActiveDirectory

## Installation

1. Clone this repository or download the desired script files
2. Import the functions into your PowerShell session:
```powershell
# Import a specific function
. .\Get-ADBitlockerRecoveryKey.ps1

# Or import all functions (once more are added)
Get-ChildItem -Path .\*.ps1 | ForEach-Object { . $_.FullName }
```

## Available Tools

### Get-ADBitlockerRecoveryKey

Retrieves BitLocker recovery keys for specified computers from Active Directory.

#### Features
- Retrieves all BitLocker recovery keys for a computer, sorted by creation date
- Supports pipeline input for processing multiple computers
- Includes detailed error handling and verbose output
- Returns structured output with computer name, recovery key, and creation date

#### Usage

```powershell
# Get recovery key for a single computer
Get-ADBitlockerRecoveryKey -ComputerName "PC01"

# Get recovery keys for multiple computers
"PC01", "PC02" | Get-ADBitlockerRecoveryKey

# Get recovery keys with verbose output
Get-ADBitlockerRecoveryKey -ComputerName "PC01" -Verbose
```

#### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| ComputerName | String | Yes | The name of the computer to retrieve BitLocker recovery keys for. Accepts pipeline input. |

#### Output

Returns a PSCustomObject for each recovery key with the following properties:
- ComputerName: Name of the computer
- RecoveryKey: BitLocker recovery key
- CreatedDate: Date when the recovery key was created

#### Requirements
- Active Directory PowerShell module
- Appropriate permissions to read BitLocker information from AD

---

## Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

## License

This project is licensed under the MIT License - see the LICENSE file for details.
