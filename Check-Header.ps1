# http://learningpcs.blogspot.com/2012/07/powershell-v3-check-file-headers.html
# https://en.wikipedia.org/wiki/List_of_file_signatures
# http://www.garykessler.net/library/file_sigs.html

function Check-Header {
    param (
        $path
    )
    
    $path = Resolve-FullPath $path

    # Hexidecimal signatures for expected files
    $known = @'
"Extension","Header"
"3gp","66 74 79 70 33 67"
"7z","37 7A BC AF 27 1C"
"8sv","38 53 56 58"
"8svx","46 4F 52 4D nn nn nn nn"
"acbm","46 4F 52 4D nn nn nn nn"
"aif","41 49 46 46"
"aiff","46 4F 52 4D nn nn nn nn"
"anbm","46 4F 52 4D nn nn nn nn"
"anim","46 4F 52 4D nn nn nn nn "
"asf","30 26 B2 75 8E 66 CF 11"
"avi","52 49 46 46 nn nn nn nn "
"bac","42 41 43 4B 4D 49 4B 45"
"bpg","42 50 47 FB"
"cab","4D 53 43 46"
"cin","80 2A 5F D7"
"class","CA FE BA BE"
"cmus","46 4F 52 4D nn nn nn nn"
"cr2","49 49 2A 00 10 00 00 00"
"crx","43 72 32 34"
"cwk","05 07 00 00 42 4F 42 4F"
"cwk","06 07 E1 00 42 4F 42 4F"
"dat","50 4D 4F 43 43 4D 4F 43"
"DBA","BE BA FE CA"
"DBA","00 01 42 44"
"dex","64 65 78 0A 30 33 35 00"
"djvu","41 54 26 54 46 4F 52 4D nn nn nn nn 44 4A 56"
"dmg","78 01 73 0D 62 62 60"
"doc","D0 CF 11 E0 A1 B1 1A E1"
"dpx","53 44 50 58"
"exr","76 2F 31 01"
"fax","46 41 58 58"
"faxx","46 4F 52 4D nn nn nn nn"
"fh8","41 47 44 33"
"fits","53 49 4D 50 4C 45 20 20"
"flac","66 4C 61 43"
"flif","46 4C 49 46"
"ftxt","46 4F 52 4D nn nn nn nn"
"gif","47 49 46 38 37 61"
"ico","00 00 01 00"
"idx","49 4E 44 58"
"iff","41 43 42 4D"
"iff","41 4E 42 4D"
"iff","41 4E 49 4D"
"iff","46 4F 52 4D nn nn nn nn"
"ilbm","46 4F 52 4D nn nn nn nn"
"iso","43 44 30 30 31"
"jpg","FF D8 FF DB"
"lbm","49 4C 42 4D"
"lz","4C 5A 49 50"
"lz4","04 22 4D 18"
"mid","4D 54 68 64"
"mkv","1A 45 DF A3"
"MLV","4D 4C 56 49"
"mus","43 4D 55 53"
"nes","4E 45 53 1A"
"ods","50 4B 05 06"
"ogg","4F 67 67 53"
"PDB","00 00 00 00 00 00 00 00"
"pdf","25 50 44 46"
"png","89 50 4E 47 0D 0A 1A 0A"
"ps","25 21 50 53"
"psd","38 42 50 53"
"rar","52 61 72 21 1A 07 00"
"rar","52 61 72 21 1A 07 01 00"
"smu","53 4D 55 53"
"smus","46 4F 52 4D nn nn nn nn"
"stg","4D 49 4C 20"
"tar","75 73 74 61 72 00 30 30"
"TDA","00 01 44 54"
"tif","49 49 2A 00"
"toast","45 52 02 00 00 00"
"tox","74 6F 78 33"
"txt","46 54 58 54"
"vsdx","50 4B 07 08"
"wav","52 49 46 46 nn nn nn nn"
"wma","A6 D9 00 AA 00 62 CE 6C"
"xar","78 61 72 21"
"yuv","59 55 56 4E"
"yuvn","46 4F 52 4D nn nn nn nn"
"zip","50 4B 03 04"
"epub","50 4B 03 04 0A 00 02 00"
'@ | ConvertFrom-Csv | sort {$_.header.length} -Descending
    
    $known | % {$_.header = $_.header -replace '\s'}
    
    try {
        # Get content of each file (up to 4 bytes) for analysis
        $HeaderAsHexString = New-Object System.Text.StringBuilder
        [Byte[]](Get-Content -Path $path -TotalCount 4 -Encoding Byte -ea Stop) | % {
            if (("{0:X}" -f $_).length -eq 1) {
                $null = $HeaderAsHexString.Append('0{0:X}' -f $_)
            } else {
                $null = $HeaderAsHexString.Append('{0:X}' -f $_)
            }
        }
      
        # Validate file header
        # might change .startswith() to -match.
        # might remove 'select -f 1' to get all possible matching extensions, or just somehow make it a better match.
        $known | ? {$_.header.startswith($HeaderAsHexString.ToString())} | select -f 1 | % {
            [pscustomobject]@{
                File = $path
                CurrentExt = (gi $path).Extension
                RealExt = $_.extension
            }
        }
    } catch {}
}
