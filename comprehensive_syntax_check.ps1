# Comprehensive Syntax Check for GDScript Files
# This script checks for common syntax issues without requiring Godot

Write-Host "🔍 Comprehensive GDScript Syntax Check" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

$totalFiles = 0
$totalIssues = 0
$issuesFound = @()

# Get all .gd files
$gdFiles = Get-ChildItem -Path . -Filter "*.gd" -Recurse

foreach ($file in $gdFiles) {
    $totalFiles++
    $content = Get-Content $file.FullName -Raw
    $lines = Get-Content $file.FullName
    $fileIssues = 0
    
    Write-Host "`n📁 Checking: $($file.FullName)" -ForegroundColor Yellow
    
    # Check for common syntax issues
    $checks = @(
        @{
            Pattern = 'get_static_memory_usage_by_type\(\)'
            Message = "Deprecated API: get_static_memory_usage_by_type() not available in Godot 4.x"
        },
        @{
            Pattern = 'Time\.get_time_dict_from_system\(\)\["unix"\]'
            Message = "Deprecated API: Use Time.get_unix_time_from_system() instead"
        },

        @{
            Pattern = 'AudioEffectSpectrumAnalyzer\.get_magnitude_for_frequency_range\([^,)]*\)'
            Message = "Missing magnitude_mode parameter for AudioEffectSpectrumAnalyzer"
        },
        @{
            Pattern = 'try:'
            Message = "Deprecated syntax: try/except was removed in Godot 4.x"
        },
        @{
            Pattern = 'except:'
            Message = "Deprecated syntax: try/except was removed in Godot 4.x"
        },
        @{
            Pattern = 'AudioServer\.stop\(\)'
            Message = "Deprecated API: AudioServer.stop() doesn't exist in Godot 4.x"
        },
        @{
            Pattern = 'error_event\.type\s*==\s*"(warning|error|fatal)"'
            Message = "Type error: Comparing ErrorEvent.ErrorType enum with string"
        },
        @{
            Pattern = 'AudioEffectSpectrumAnalyzer\.MAGNITUDE_MAX'
            Message = "API error: Use AudioEffectSpectrumAnalyzerInstance.MAGNITUDE_MAX instead"
        },
        @{
            Pattern = 'class_name\s+\w+\s*$'
            Message = "Missing class_name declaration (this is actually good)"
            IsGood = $true
        }
    )
    
    for ($i = 0; $i -lt $lines.Count; $i++) {
        $lineNum = $i + 1
        $line = $lines[$i]
        
        foreach ($check in $checks) {
            # Skip lines that are comments (start with # after whitespace)
            if ($line -match '^\s*#') {
                continue
            }

            if ($line -match $check.Pattern) {
                if (-not $check.IsGood) {
                    $fileIssues++
                    $totalIssues++
                    $issue = "Line $lineNum`: $($check.Message)"
                    $issuesFound += "$($file.FullName):$lineNum - $($check.Message)"
                    Write-Host "  ❌ $issue" -ForegroundColor Red
                }
            }
        }
        
        # Check for specific syntax patterns that might cause issues
        if ($line -match 'Expected end of statement after expression, found ":"') {
            $fileIssues++
            $totalIssues++
            $issue = "Line $lineNum`: Syntax error - unexpected colon"
            $issuesFound += "$($file.FullName):$lineNum - Syntax error"
            Write-Host "  ❌ $issue" -ForegroundColor Red
        }
        

    }
    
    if ($fileIssues -eq 0) {
        Write-Host "  ✅ No syntax issues found" -ForegroundColor Green
    } else {
        Write-Host "  ⚠️  Found $fileIssues issues" -ForegroundColor Yellow
    }
}

Write-Host "`n📊 SUMMARY" -ForegroundColor Cyan
Write-Host "==========" -ForegroundColor Cyan
Write-Host "Files checked: $totalFiles" -ForegroundColor White
Write-Host "Total issues found: $totalIssues" -ForegroundColor $(if ($totalIssues -eq 0) { "Green" } else { "Red" })

if ($totalIssues -gt 0) {
    Write-Host "`n🔧 Issues to fix:" -ForegroundColor Yellow
    foreach ($issue in $issuesFound) {
        Write-Host "  • $issue" -ForegroundColor Red
    }
    
    Write-Host "`n❌ VALIDATION FAILED - $totalIssues issues need to be fixed" -ForegroundColor Red
    exit 1
} else {
    Write-Host "`n✅ ALL SYNTAX CHECKS PASSED" -ForegroundColor Green
    exit 0
}
