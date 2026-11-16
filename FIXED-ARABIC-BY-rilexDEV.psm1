Add-Type -TypeDefinition @"
using System;
public class ArabicFixer {
    public static string Fix(string text) {
        if (string.IsNullOrEmpty(text)) return text;
        char[] chars = text.ToCharArray();
        Array.Reverse(chars);
        return new string(chars);
    }
}
"@
$script:IsEnabled = $false
function Enable-FixedArabic {
    if ($script:IsEnabled) { Write-Warning "Already enabled."; return }
    $script:IsEnabled = $true
    function global:Out-Default {
        $input | ForEach-Object {
            if ($_ -is [string]) {
                [ArabicFixer]::Fix($_)
            } else {
                $_
            }
        } | Microsoft.PowerShell.Core\Out-Default
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