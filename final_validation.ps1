# Final validation script for Rhythm Chess project
# Checks for critical issues that would prevent the project from running

Write-Host "=== FINAL PROJECT VALIDATION ===" -ForegroundColor Cyan

$criticalErrors = @()
$warnings = @()
$totalChecks = 0
$passedChecks = 0

# Function to check file and report
function Test-FileExists {
    param($filePath, $description)
    $global:totalChecks++
    if (Test-Path $filePath) {
        Write-Host "✅ $description" -ForegroundColor Green
        $global:passedChecks++
        return $true
    } else {
        Write-Host "❌ $description" -ForegroundColor Red
        $global:criticalErrors += "Missing file: $filePath"
        return $false
    }
}

# Function to check content
function Test-FileContent {
    param($filePath, $pattern, $description, $isError = $true)
    $global:totalChecks++
    if (Test-Path $filePath) {
        $content = Get-Content $filePath -Raw
        if ($content -match $pattern) {
            Write-Host "✅ $description" -ForegroundColor Green
            $global:passedChecks++
            return $true
        } else {
            if ($isError) {
                Write-Host "❌ $description" -ForegroundColor Red
                $global:criticalErrors += "${filePath}: $description"
            } else {
                Write-Host "⚠️  $description" -ForegroundColor Yellow
                $global:warnings += "${filePath}: $description"
            }
            return $false
        }
    } else {
        if ($isError) {
            Write-Host "❌ $description (file missing)" -ForegroundColor Red
            $global:criticalErrors += "Missing file: $filePath"
        }
        return $false
    }
}

Write-Host "`n1. CHECKING CORE PROJECT FILES..." -ForegroundColor Yellow

# Core files
Test-FileExists "project.godot" "Project configuration exists"
Test-FileExists "scenes/main/main.tscn" "Main scene file exists"
Test-FileExists "README.md" "Project documentation exists"

Write-Host "`n2. CHECKING AUTOLOAD SCRIPTS..." -ForegroundColor Yellow

# Autoload files
Test-FileExists "autoload/event_bus.gd" "EventBus autoload exists"
Test-FileExists "autoload/game_manager.gd" "GameManager autoload exists"
Test-FileExists "autoload/audio_manager.gd" "AudioManager autoload exists"
Test-FileExists "autoload/settings_manager.gd" "SettingsManager autoload exists"

# Check autoload class names
Test-FileContent "autoload/event_bus.gd" "class_name EventBusManager" "EventBus has class_name declaration"
Test-FileContent "autoload/game_manager.gd" "class_name GameManagerSingleton" "GameManager has class_name declaration"
Test-FileContent "autoload/audio_manager.gd" "class_name AudioManagerSingleton" "AudioManager has class_name declaration"
Test-FileContent "autoload/settings_manager.gd" "class_name SettingsManagerSingleton" "SettingsManager has class_name declaration"

Write-Host "`n3. CHECKING DATA MODELS..." -ForegroundColor Yellow

# Data model files
Test-FileExists "scripts/data/models/beat_event.gd" "BeatEvent model exists"
Test-FileExists "scripts/data/models/audio_data.gd" "AudioData model exists"
Test-FileExists "scripts/data/models/error_event.gd" "ErrorEvent model exists"
Test-FileExists "scripts/data/models/board_state.gd" "BoardState model exists"

# Check data model class names
Test-FileContent "scripts/data/models/beat_event.gd" "class_name BeatEvent" "BeatEvent has class_name declaration"
Test-FileContent "scripts/data/models/audio_data.gd" "class_name AudioData" "AudioData has class_name declaration"
Test-FileContent "scripts/data/models/error_event.gd" "class_name ErrorEvent" "ErrorEvent has class_name declaration"
Test-FileContent "scripts/data/models/board_state.gd" "class_name BoardState" "BoardState has class_name declaration"

Write-Host "`n4. CHECKING TIMING CORE..." -ForegroundColor Yellow

# Timing core files
Test-FileExists "scripts/timing_core/interfaces/i_timing_source.gd" "ITimingSource interface exists"
Test-FileExists "scripts/timing_core/interfaces/i_beat_predictor.gd" "IBeatPredictor interface exists"
Test-FileExists "scripts/timing_core/latency_normalizer.gd" "LatencyNormalizer exists"

Write-Host "`n5. CHECKING FOR CRITICAL API ISSUES..." -ForegroundColor Yellow

# Check for deprecated Time API
$gdFiles = Get-ChildItem -Path . -Filter "*.gd" -Recurse
$deprecatedTimeAPI = $false

foreach ($file in $gdFiles) {
    $content = Get-Content $file.FullName -Raw
    if ($content -match "Time\.get_time_dict_from_system") {
        $criticalErrors += "$($file.Name): Uses deprecated Time.get_time_dict_from_system() API"
        $deprecatedTimeAPI = $true
    }
}

$totalChecks++
if (-not $deprecatedTimeAPI) {
    Write-Host "✅ No deprecated Time API usage found" -ForegroundColor Green
    $passedChecks++
} else {
    Write-Host "❌ Deprecated Time API usage found" -ForegroundColor Red
}

Write-Host "`n6. CHECKING PROJECT CONFIGURATION..." -ForegroundColor Yellow

# Check project.godot autoload configuration
Test-FileContent "project.godot" 'EventBus=".*res://autoload/event_bus.gd"' "EventBus autoload configured"
Test-FileContent "project.godot" 'GameManager=".*res://autoload/game_manager.gd"' "GameManager autoload configured"
Test-FileContent "project.godot" 'AudioManager=".*res://autoload/audio_manager.gd"' "AudioManager autoload configured"
Test-FileContent "project.godot" 'SettingsManager=".*res://autoload/settings_manager.gd"' "SettingsManager autoload configured"

# Check main scene configuration
Test-FileContent "project.godot" 'run/main_scene="res://scenes/main/main.tscn"' "Main scene configured correctly"

Write-Host "`n" + "="*60 -ForegroundColor Cyan
Write-Host "FINAL VALIDATION RESULTS" -ForegroundColor Cyan
Write-Host "="*60 -ForegroundColor Cyan

Write-Host "`nTotal Checks: $totalChecks" -ForegroundColor White
Write-Host "Passed: $passedChecks" -ForegroundColor Green
Write-Host "Failed: $($totalChecks - $passedChecks)" -ForegroundColor Red
Write-Host "Success Rate: $([math]::Round(($passedChecks / $totalChecks) * 100, 1))%" -ForegroundColor White

if ($criticalErrors.Count -eq 0) {
    Write-Host "`n🎉 ALL CRITICAL VALIDATIONS PASSED!" -ForegroundColor Green
    Write-Host "✅ Project structure is complete" -ForegroundColor Green
    Write-Host "✅ All required files exist" -ForegroundColor Green
    Write-Host "✅ Configuration is correct" -ForegroundColor Green
    Write-Host "✅ No critical API issues found" -ForegroundColor Green
    Write-Host "`n🚀 PROJECT IS READY FOR GODOT!" -ForegroundColor Green
    
    if ($warnings.Count -gt 0) {
        Write-Host "`n⚠️  WARNINGS (non-critical):" -ForegroundColor Yellow
        foreach ($warning in $warnings) {
            Write-Host "  - $warning" -ForegroundColor Yellow
        }
    }
} else {
    Write-Host "`n❌ CRITICAL ERRORS FOUND:" -ForegroundColor Red
    foreach ($error in $criticalErrors) {
        Write-Host "  - $error" -ForegroundColor Red
    }
    Write-Host "`n🔧 These errors must be fixed before the project can run in Godot" -ForegroundColor Yellow
}

Write-Host "`n=== VALIDATION COMPLETE ===" -ForegroundColor Cyan
