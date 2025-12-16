# Static code analysis for GDScript files
# Checks for common syntax issues and API problems

Write-Host "=== STATIC CODE ANALYSIS ===" -ForegroundColor Cyan

$errors = @()
$warnings = @()
$totalFiles = 0

# Get all .gd files
$gdFiles = Get-ChildItem -Path . -Filter "*.gd" -Recurse

Write-Host "Found $($gdFiles.Count) GDScript files to analyze..." -ForegroundColor Yellow

foreach ($file in $gdFiles) {
    $totalFiles++
    $content = Get-Content $file.FullName -Raw
    $fileName = $file.FullName.Replace((Get-Location).Path, "").TrimStart('\')
    
    Write-Host "`nAnalyzing: $fileName" -ForegroundColor Cyan
    
    # Check 1: Deprecated Time API usage
    if ($content -match "Time\.get_time_dict_from_system") {
        $errors += "${fileName}: Uses deprecated Time.get_time_dict_from_system() - should use Time.get_unix_time_from_system()"
        Write-Host "  ❌ Deprecated Time API found" -ForegroundColor Red
    } else {
        Write-Host "  ✅ Time API usage OK" -ForegroundColor Green
    }

    # Check 2: AudioEffectSpectrumAnalyzer API usage
    if ($content -match "get_magnitude_for_frequency_range\([^,)]+\)") {
        $errors += "${fileName}: Incorrect AudioEffectSpectrumAnalyzer API - missing magnitude_mode parameter"
        Write-Host "  ❌ Incorrect AudioEffectSpectrumAnalyzer API" -ForegroundColor Red
    } else {
        Write-Host "  ✅ AudioEffectSpectrumAnalyzer API usage OK" -ForegroundColor Green
    }
    
    # Check 3: Class name declarations
    if ($content -match "class_name\s+\w+") {
        Write-Host "  ✅ Has class_name declaration" -ForegroundColor Green
    } else {
        if ($fileName -match "(autoload|scripts)" -and $fileName -notmatch "(test_|mock_)") {
            $warnings += "${fileName}: Missing class_name declaration (recommended for core classes)"
            Write-Host "  ⚠️  Missing class_name declaration" -ForegroundColor Yellow
        }
    }
    
    # Check 4: Extends declaration
    if ($content -match "extends\s+\w+") {
        Write-Host "  ✅ Has extends declaration" -ForegroundColor Green
    } else {
        $errors += "${fileName}: Missing extends declaration"
        Write-Host "  ❌ Missing extends declaration" -ForegroundColor Red
    }
    
    # Check 5: Basic syntax issues
    $lines = $content -split "`n"
    $lineNum = 0
    foreach ($line in $lines) {
        $lineNum++
        
        # Check for common syntax errors
        if ($line -match "^\s*func\s+\w+\([^)]*\)\s*->\s*\w+\s*:?\s*$" -and $line -notmatch ":$") {
            $warnings += "${fileName}:${lineNum}: Function declaration might be missing colon"
        }

        # Check for incorrect signal connections
        if ($line -match "\.connect\(" -and $line -notmatch "\.connect\(\w+\.\w+\)" -and $line -notmatch "\.connect\(_\w+\)") {
            $warnings += "${fileName}:${lineNum}: Signal connection might have incorrect syntax"
        }
    }
    
    # Check 6: Required methods for specific file types
    if ($fileName -match "autoload") {
        if ($content -notmatch "_ready\(\)") {
            $warnings += "${fileName}: Autoload script missing _ready() method (recommended)"
            Write-Host "  ⚠️  Missing _ready() method" -ForegroundColor Yellow
        } else {
            Write-Host "  ✅ Has _ready() method" -ForegroundColor Green
        }
    }
    
    # Check 7: Interface compliance
    if ($fileName -match "interfaces/i_") {
        if ($content -notmatch "## Abstract|# Abstract") {
            $warnings += "${fileName}: Interface file should have abstract documentation"
            Write-Host "  ⚠️  Missing abstract documentation" -ForegroundColor Yellow
        } else {
            Write-Host "  ✅ Has abstract documentation" -ForegroundColor Green
        }
    }
}

# Summary
Write-Host "`n" + "="*60 -ForegroundColor Cyan
Write-Host "STATIC ANALYSIS COMPLETE" -ForegroundColor Cyan
Write-Host "="*60 -ForegroundColor Cyan

Write-Host "`nFiles Analyzed: $totalFiles" -ForegroundColor White
Write-Host "Errors Found: $($errors.Count)" -ForegroundColor $(if ($errors.Count -eq 0) { "Green" } else { "Red" })
Write-Host "Warnings Found: $($warnings.Count)" -ForegroundColor $(if ($warnings.Count -eq 0) { "Green" } else { "Yellow" })

if ($errors.Count -gt 0) {
    Write-Host "`n❌ CRITICAL ERRORS:" -ForegroundColor Red
    foreach ($error in $errors) {
        Write-Host "  - $error" -ForegroundColor Red
    }
}

if ($warnings.Count -gt 0) {
    Write-Host "`n⚠️  WARNINGS:" -ForegroundColor Yellow
    foreach ($warning in $warnings) {
        Write-Host "  - $warning" -ForegroundColor Yellow
    }
}

if ($errors.Count -eq 0) {
    Write-Host "`n🎉 NO CRITICAL ERRORS FOUND!" -ForegroundColor Green
    Write-Host "✅ Code appears to be syntactically correct" -ForegroundColor Green
    
    if ($warnings.Count -eq 0) {
        Write-Host "✅ No warnings - code quality is excellent!" -ForegroundColor Green
    } else {
        Write-Host "⚠️  $($warnings.Count) warnings found - consider addressing for better code quality" -ForegroundColor Yellow
    }
} else {
    Write-Host "`n🔧 $($errors.Count) critical errors must be fixed before the project can run" -ForegroundColor Red
}

Write-Host "`n=== ANALYSIS COMPLETE ===" -ForegroundColor Cyan
