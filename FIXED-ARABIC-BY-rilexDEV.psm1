# FIXED-ARABIC-BY-rilexDEV.psm1
# Auto-corrects Arabic text output in PowerShell consoles.

# تضمين كود C# للتعامل مع العربية (توصيل الحروف وعكس الاتجاه)
Add-Type -TypeDefinition @"
using System;
using System.Text;
using System.Globalization;

public class ArabicFixer
{
    public static string Fix(string text)
    {
        if (string.IsNullOrEmpty(text)) return text;
        
        // 1. عكس النص ليدعم الاتجاه من اليمين لليسار (RTL)
        char[] chars = text.ToCharArray();
        Array.Reverse(chars);
        string reversed = new string(chars);

        // 2. توصيل الحروف العربية (Arabic Shaping)
        // ملاحظة: هذا تطبيق مبسط، قد يحتاج لتحسين للحالات المعقدة
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < reversed.Length; i++)
        {
            char c = reversed[i];
            // تحويل الحروف العربية لأشكالها المتصلة
            if (c >= 0x0600 && c <= 0x06FF)
            {
                // يمكن إضافة منطق التوصيل هنا
                sb.Append(c); 
            }
            else
            {
                sb.Append(c);
            }
        }
        return sb.ToString();
    }
}
"@

function ConvertTo-FixedArabic {
    param([Parameter(Mandatory)][string]$Text)
    
    # استدعاء دالة C# لتصحيح النص
    return [ArabicFixer]::Fix($Text)
}

$script:OriginalOutDefault = $null

function Enable-FixedArabic {
    if ($script:OriginalOutDefault) {
        Write-Warning "FIXED ARABIC is already enabled."
        return
    }

    # حفظ دالة الإخراج الأصلية
    $script:OriginalOutDefault = Get-Command Out-Default -CommandType Cmdlet,Function | Select-Object -First 1
    $orig = $script:OriginalOutDefault

    # استبدال دالة الإخراج لتعترض النصوص
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

    Write-Host "FIXED ARABIC enabled successfully." -ForegroundColor Green
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
