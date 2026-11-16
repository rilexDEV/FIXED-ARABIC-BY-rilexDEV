Add-Type -TypeDefinition @"
using System;
using System.Collections.Generic;
using System.Text;

public class ArabicFixerV31
{
    static Dictionary<char, char[]> charsMap = new Dictionary<char, char[]>()
    {
        {'\u0621', new char[]{'\uFE80', '\uFE80', '\uFE80', '\uFE80'}},
        {'\u0622', new char[]{'\uFE81', '\uFE81', '\uFE81', '\uFE82'}},
        {'\u0623', new char[]{'\uFE83', '\uFE83', '\uFE83', '\uFE84'}},
        {'\u0624', new char[]{'\uFE85', '\uFE85', '\uFE85', '\uFE86'}},
        {'\u0625', new char[]{'\uFE87', '\uFE87', '\uFE87', '\uFE88'}},
        {'\u0626', new char[]{'\uFE89', '\uFE8B', '\uFE8C', '\uFE8A'}},
        {'\u0627', new char[]{'\uFE8D', '\uFE8D', '\uFE8D', '\uFE8E'}},
        {'\u0628', new char[]{'\uFE8F', '\uFE91', '\uFE92', '\uFE90'}},
        {'\u0629', new char[]{'\uFE93', '\uFE93', '\uFE94', '\uFE94'}},
        {'\u062A', new char[]{'\uFE95', '\uFE97', '\uFE98', '\uFE96'}},
        {'\u062B', new char[]{'\uFE99', '\uFE9B', '\uFE9C', '\uFE9A'}},
        {'\u062C', new char[]{'\uFE9D', '\uFE9F', '\uFEA0', '\uFE9E'}},
        {'\u062D', new char[]{'\uFEA1', '\uFEA3', '\uFEA4', '\uFEA2'}},
        {'\u062E', new char[]{'\uFEA5', '\uFEA7', '\uFEA8', '\uFEA6'}},
        {'\u062F', new char[]{'\uFEA9', '\uFEA9', '\uFEAA', '\uFEAA'}},
        {'\u0630', new char[]{'\uFEAB', '\uFEAB', '\uFEAC', '\uFEAC'}},
        {'\u0631', new char[]{'\uFEAD', '\uFEAD', '\uFEAE', '\uFEAE'}},
        {'\u0632', new char[]{'\uFEAF', '\uFEAF', '\uFEB0', '\uFEB0'}},
        {'\u0633', new char[]{'\uFEB1', '\uFEB3', '\uFEB4', '\uFEB2'}},
        {'\u0634', new char[]{'\uFEB5', '\uFEB7', '\uFEB8', '\uFEB6'}},
        {'\u0635', new char[]{'\uFEB9', '\uFEBB', '\uFEBC', '\uFEBA'}},
        {'\u0636', new char[]{'\uFEBD', '\uFEBF', '\uFEC0', '\uFEBE'}},
        {'\u0637', new char[]{'\uFEC1', '\uFEC3', '\uFEC4', '\uFEC2'}},
        {'\u0638', new char[]{'\uFEC5', '\uFEC7', '\uFEC8', '\uFEC6'}},
        {'\u0639', new char[]{'\uFEC9', '\uFECB', '\uFECC', '\uFECA'}},
        {'\u063A', new char[]{'\uFECD', '\uFECF', '\uFED0', '\uFECE'}},
        {'\u0641', new char[]{'\uFED1', '\uFED3', '\uFED4', '\uFED2'}},
        {'\u0642', new char[]{'\uFED5', '\uFED7', '\uFED8', '\uFED6'}},
        {'\u0643', new char[]{'\uFED9', '\uFEDB', '\uFEDC', '\uFEDA'}},
        {'\u0644', new char[]{'\uFEDD', '\uFEDF', '\uFEE0', '\uFEDE'}},
        {'\u0645', new char[]{'\uFEE1', '\uFEE3', '\uFEE4', '\uFEE2'}},
        {'\u0646', new char[]{'\uFEE5', '\uFEE7', '\uFEE8', '\uFEE6'}},
        {'\u0647', new char[]{'\uFEE9', '\uFEEB', '\uFEEC', '\uFEEA'}},
        {'\u0648', new char[]{'\uFEED', '\uFEED', '\uFEEE', '\uFEEE'}},
        {'\u0649', new char[]{'\uFEEF', '\uFEEF', '\uFEF0', '\uFEF0'}},
        {'\u064A', new char[]{'\uFEF1', '\uFEF3', '\uFEF4', '\uFEF2'}}
    };

    static bool IsArabic(char c) { return c >= 0x0600 && c <= 0x06FF; }
    
    static bool CanConnectLeft(char c) {
        if (c == '\u0621' || c == '\u0622' || c == '\u0623' || c == '\u0624' || c == '\u0625' || c == '\u0626' || 
            c == '\u0627' || c == '\u062F' || c == '\u0630' || c == '\u0631' || c == '\u0632' || c == '\u0648' || 
            c == '\u0649') return false;
        return true;
    }

    public static string Fix(string text)
    {
        if (string.IsNullOrEmpty(text)) return text;
        
        // 1. توصيل الحروف
        StringBuilder sb = new StringBuilder();
        for (int i = 0; i < text.Length; i++) {
            char current = text[i];
            if (charsMap.ContainsKey(current)) {
                bool connectPrev = (i > 0 && IsArabic(text[i-1]) && CanConnectLeft(text[i-1]));
                bool connectNext = (i < text.Length - 1 && IsArabic(text[i+1]));
                
                char[] forms = charsMap[current];
                if (connectPrev && connectNext) sb.Append(forms[2]); // Medial
                else if (connectPrev) sb.Append(forms[3]); // Final
                else if (connectNext) sb.Append(forms[1]); // Initial
                else sb.Append(forms[0]); // Isolated
            } else {
                sb.Append(current);
            }
        }

        // 2. ترتيب الكلمات (Bidi) - نعكس ترتيب الكلمات فقط، ونعكس حروف الكلمات العربية
        string shaped = sb.ToString();
        string[] words = shaped.Split(' ');
        Array.Reverse(words);
        for (int i = 0; i < words.Length; i++) {
            bool isLtr = false;
            foreach(char c in words[i]) { 
                if ((c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || (c >= '0' && c <= '9')) { 
                    isLtr = true; break; 
                } 
            }
            if (!isLtr) {
                char[] chars = words[i].ToCharArray();
                Array.Reverse(chars);
                words[i] = new string(chars);
            }
        }
        return string.Join(" ", words);
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
                [ArabicFixerV31]::Fix($_)
            } else {
                $_
            }
        } | Microsoft.PowerShell.Core\Out-Default
    }
    Write-Host "FIXED ARABIC (v0.3.1) enabled successfully." -ForegroundColor Green
}
function Disable-FixedArabic {
    if (-not $script:IsEnabled) { Write-Warning "Not enabled."; return }
    Remove-Item function:global:Out-Default -ErrorAction SilentlyContinue
    $script:IsEnabled = $false
    Write-Host "FIXED ARABIC disabled." -ForegroundColor Yellow
}
Export-ModuleMember -Function Enable-FixedArabic, Disable-FixedArabic