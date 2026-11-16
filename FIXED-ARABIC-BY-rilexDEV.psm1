# FIXED-ARABIC-BY-rilexDEV.psm1

# دالة مساعدة لتطبيق BiDi وتوصيل الحروف (هذا الجزء هو الأصعب)
function ConvertTo-FixedArabic {
    param([string]$Text)
    
    # هنا يجب استدعاء مكتبة حقيقية لتوصيل الحروف وتطبيق BiDi.
    # للتوضيح فقط، نقوم بعكس النص (هذا ليس حلاً كاملاً!):
    $charArray = $Text.ToCharArray()
    [array]::Reverse($charArray)
    return (-join $charArray)
}

# حفظ دالة Out-Default الأصلية
$script:OriginalOutDefault = $null

function Enable-FixedArabic {
    if ($script:OriginalOutDefault) { return } # مفعلة بالفعل
    
    $script:OriginalOutDefault = Get-Command Out-Default -CommandType Function -ErrorAction SilentlyContinue
    if (-not $script:OriginalOutDefault) {
        # إذا لم تكن موجودة كدالة، قد تكون Cmdlet. نحتاج لطريقة أخرى.
        # هذا المثال يفترض وجودها كدالة.
    }

    # إنشاء دالة وكيل (Proxy) أو استبدال بسيط
    function global:Out-Default {
        $input | ForEach-Object {
            if ($_ -is [string]) {
                ConvertTo-FixedArabic $_
            } else {
                $_
            }
        } | & $script:OriginalOutDefault
    }
}

function Disable-FixedArabic {
    if ($script:OriginalOutDefault) {
        Remove-Item function:global:Out-Default -ErrorAction SilentlyContinue
        # إعادة الدالة الأصلية إذا لزم الأمر
        $script:OriginalOutDefault = $null
    }
}
