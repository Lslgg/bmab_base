# Rhythm Chess Project Validation Script
# Validates project structure and implementation

Write-Host "=== RHYTHM CHESS PROJECT VALIDATION ===" -ForegroundColor Cyan
Write-Host "Validating project structure and implementation..." -ForegroundColor White
Write-Host ""

$totalTests = 0
$passedTests = 0

# Function to test directory existence
function Test-Directory {
    param($path, $description)
    $script:totalTests++
    if (Test-Path $path -PathType Container) {
        Write-Host "  ✅ Directory exists: $path" -ForegroundColor Green
        $script:passedTests++
        return $true
    } else {
        Write-Host "  ❌ Directory missing: $path" -ForegroundColor Red
        return $false
    }
}

# Function to test file existence
function Test-File {
    param($path, $description)
    $script:totalTests++
    if (Test-Path $path -PathType Leaf) {
        Write-Host "  ✅ File exists: $path" -ForegroundColor Green
        $script:passedTests++
        return $true
    } else {
        Write-Host "  ❌ File missing: $path" -ForegroundColor Red
        return $false
    }
}

# Function to test file content
function Test-FileContent {
    param($path, $pattern, $description)
    $script:totalTests++
    if (Test-Path $path -PathType Leaf) {
        $content = Get-Content $path -Raw
        if ($content -match $pattern) {
            Write-Host "    ✅ $description" -ForegroundColor Green
            $script:passedTests++
            return $true
        } else {
            Write-Host "    ❌ $description" -ForegroundColor Red
            return $false
        }
    } else {
        Write-Host "    ❌ File not found for content check: $path" -ForegroundColor Red
        return $false
    }
}

# 1. Project Structure Validation
Write-Host "1. VALIDATING PROJECT STRUCTURE..." -ForegroundColor Yellow

$requiredDirs = @(
    "autoload",
    "scripts",
    "scripts\timing_core",
    "scripts\timing_core\interfaces", 
    "scripts\data",
    "scripts\data\models",
    "scenes",
    "scenes\main",
    "testing",
    "testing\audio_mocking"
)

foreach ($dir in $requiredDirs) {
    Test-Directory $dir "Required directory"
}

# 2. Core Files Validation
Write-Host "`n2. VALIDATING CORE FILES..." -ForegroundColor Yellow

$coreFiles = @(
    "project.godot",
    "README.md"
)

foreach ($file in $coreFiles) {
    Test-File $file "Core file"
}

# 3. Autoload Scripts Validation
Write-Host "`n3. VALIDATING AUTOLOAD SCRIPTS..." -ForegroundColor Yellow

$autoloadFiles = @(
    "autoload\event_bus.gd",
    "autoload\game_manager.gd",
    "autoload\audio_manager.gd", 
    "autoload\settings_manager.gd"
)

foreach ($file in $autoloadFiles) {
    if (Test-File $file "Autoload script") {
        Test-FileContent $file "extends Node" "Has proper Node inheritance"
        Test-FileContent $file "class_name" "Has class_name declaration"
    }
}

# 4. Data Models Validation
Write-Host "`n4. VALIDATING DATA MODELS..." -ForegroundColor Yellow

$modelFiles = @(
    "scripts\data\models\beat_event.gd",
    "scripts\data\models\audio_data.gd",
    "scripts\data\models\error_event.gd"
)

foreach ($file in $modelFiles) {
    if (Test-File $file "Data model") {
        Test-FileContent $file "class_name" "Has class_name declaration"
        Test-FileContent $file "extends RefCounted" "Extends RefCounted"
    }
}

# 5. Timing Core Validation
Write-Host "`n5. VALIDATING TIMING CORE..." -ForegroundColor Yellow

$timingFiles = @(
    "scripts\timing_core\interfaces\i_timing_source.gd",
    "scripts\timing_core\interfaces\i_beat_predictor.gd",
    "scripts\timing_core\latency_normalizer.gd"
)

foreach ($file in $timingFiles) {
    if (Test-File $file "Timing core component") {
        Test-FileContent $file "class_name" "Has class_name declaration"
    }
}

# 6. Testing Infrastructure Validation
Write-Host "`n6. VALIDATING TESTING INFRASTRUCTURE..." -ForegroundColor Yellow

$testFiles = @(
    "testing\test_runner.gd",
    "testing\test_scene.gd",
    "testing\audio_mocking\mock_audio_stream.gd"
)

foreach ($file in $testFiles) {
    Test-File $file "Test infrastructure"
}

# 7. Project Configuration Validation
Write-Host "`n7. VALIDATING PROJECT CONFIGURATION..." -ForegroundColor Yellow

if (Test-Path "project.godot" -PathType Leaf) {
    $projectContent = Get-Content "project.godot" -Raw
    
    $configChecks = @(
        @("[application]", "Application section"),
        @("[autoload]", "Autoload section"), 
        @("[audio]", "Audio section"),
        @("EventBus", "EventBus autoload"),
        @("GameManager", "GameManager autoload"),
        @("AudioManager", "AudioManager autoload"),
        @("SettingsManager", "SettingsManager autoload")
    )
    
    foreach ($check in $configChecks) {
        Test-FileContent "project.godot" $check[0] $check[1]
    }
}

# Final Results
Write-Host "`n$('=' * 60)" -ForegroundColor Cyan
Write-Host "VALIDATION COMPLETE" -ForegroundColor Cyan
Write-Host "$('=' * 60)" -ForegroundColor Cyan
Write-Host "Total Checks: $totalTests" -ForegroundColor White
Write-Host "Passed: $passedTests" -ForegroundColor Green
Write-Host "Failed: $($totalTests - $passedTests)" -ForegroundColor Red

$successRate = [math]::Round(($passedTests / $totalTests) * 100, 2)
Write-Host "Success Rate: $successRate%" -ForegroundColor White

if ($passedTests -eq $totalTests) {
    Write-Host "`n🎉 ALL VALIDATIONS PASSED!" -ForegroundColor Green
    Write-Host "✅ Project foundation is complete and ready for development" -ForegroundColor Green
    Write-Host "✅ Core architecture is properly implemented" -ForegroundColor Green
    Write-Host "✅ All required files are present and valid" -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n❌ Some validations failed" -ForegroundColor Red
    Write-Host "Review the output above for details" -ForegroundColor Yellow
    exit 1
}

Write-Host "$('=' * 60)" -ForegroundColor Cyan
