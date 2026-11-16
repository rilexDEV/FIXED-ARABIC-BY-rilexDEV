Add-Type -TypeDefinition @"
using System;
public class ArabicFixer
{
    public static string Fix(string text)
    {
        if (string.IsNullOrEmpty(text)) return text;
        char[] chars = text.ToCharArray();
        Array.Reverse(chars);
        return new string(chars);
    }
}
"@

$script:IsEnabled = $false
$script:OrigOutDefault = $null

function Enable-FixedArabic {
    if ($script:IsEnabled) { Write-Warning "Already enabled."; return }
    $script:IsEnabled = $true
    
    if (-not $script:OrigOutDefault) {
        $script:OrigOutDefault = Get-Command -Name Microsoft.PowerShell.Core\Out-Default -CommandType Cmdlet
    }
    $orig = $script:OrigOutDefault

    function global:Out-Default {
        [CmdletBinding()]
        param([Parameter(ValueFromPipeline = $true)]$InputObject)
        process {
            if ($InputObject -is [string]) {
                [ArabicFixer]::Fix($InputObject) | & $orig
            } else {
                $InputObject | & $orig
            }
        }
    }
    Write-Host "FIXED ARABIC enabled successfully." -ForegroundColor Green
}

function Disable-FixedArabic {
    if (-not $script:IsEnabled) { Write-Warning "Not enabled."; return }
    Remove-Item function:global:Out-Default -ErrorAction SilentlyContinue
    $script:IsEnabled = $false
    Write-Host "FIXED ARABIC disabled." -ForegroundColor Yellow
}

Export-ModuleMember -Function Enable-FixedArabic, Disable-FixedArabic
