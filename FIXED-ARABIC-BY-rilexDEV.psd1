New-ModuleManifest `
    -Path ".\FIXED-ARABIC-BY-rilexDEV.psd1" `
    -RootModule "FIXED-ARABIC-BY-rilexDEV.psm1" `
    -ModuleVersion "0.1.0" `
    -Guid ([guid]::NewGuid().ToString()) `
    -Author "rilexDEV" `
    -Description "Auto-corrects Arabic text output in PowerShell consoles." `
    -FunctionsToExport @("Enable-FixedArabic","Disable-FixedArabic","ConvertTo-FixedArabic") `
    -Tags @("arabic","rtl","bidi","terminal","fix") `
    -PowerShellVersion "5.1"

Write-Host ".psd1 created." -ForegroundColor Green
