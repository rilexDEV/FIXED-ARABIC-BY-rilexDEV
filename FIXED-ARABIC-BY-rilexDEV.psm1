$psm1 = @'
# FIXED-ARABIC-BY-rilexDEV.psm1
# Auto-corrects Arabic text output in PowerShell consoles.

function ConvertTo-FixedArabic {
    param([Parameter(Mandatory)][string]$Text)

    # TODO: real BiDi + Arabic shaping goes here.
    # For now this is a pass-through placeholder so the module is publishable.
    return $Text
}

$script:OriginalOutDefault = $null

function Enable-FixedArabic {
    if ($script:OriginalOutDefault) {
        Write-Warning "FIXED ARABIC is already enabled."
        return
    }

    $script:OriginalOutDefault = Get-Command Out-Default -CommandType Cmdlet,Function | Select-Object -First 1
    $orig = $script:OriginalOutDefault

    function global:Out-Default {
        process {
            $input | ForEach-Object {
                if ($_ -is [string]) {
                    ConvertTo-FixedArabic -Text $_
                } else {
                    $_
                }
            } | & $orig
        }
    }

    Write-Host "FIXED ARABIC enabled." -ForegroundColor Green
}

function Disable-FixedArabic {
    if (-not $script:OriginalOutDefault) {
        Write-Warning "FIXED ARABIC is not enabled."
        return
    }
    Remove-Item function:global:Out-Default -ErrorAction SilentlyContinue
    $script:OriginalOutDefault = $null
    Write-Host "FIXED ARABIC disabled." -ForegroundColor Yellow
}

Export-ModuleMember -Function Enable-FixedArabic, Disable-FixedArabic, ConvertTo-FixedArabic
'@

Set-Content -Path ".\FIXED-ARABIC-BY-rilexDEV.psm1" -Value $psm1 -Encoding UTF8
Write-Host ".psm1 created." -ForegroundColor Green
