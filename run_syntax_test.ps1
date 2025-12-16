# PowerShell script to run comprehensive syntax testing
# This script attempts to find and run Godot to test our project

Write-Host "=== RHYTHM CHESS SYNTAX TESTING ===" -ForegroundColor Cyan
Write-Host "Searching for Godot executable..." -ForegroundColor Yellow

# Common Godot installation paths
$godotPaths = @(
    "godot",
    "godot.exe", 
    "C:\Program Files\Godot\godot.exe",
    "C:\Program Files (x86)\Godot\godot.exe",
    "C:\Godot\godot.exe",
    "$env:USERPROFILE\AppData\Local\Godot\godot.exe",
    "$env:USERPROFILE\Desktop\Godot\godot.exe",
    "$env:USERPROFILE\Downloads\Godot\godot.exe"
)

$godotFound = $false
$godotPath = ""

foreach ($path in $godotPaths) {
    try {
        if (Get-Command $path -ErrorAction SilentlyContinue) {
            $godotPath = $path
            $godotFound = $true
            Write-Host "✅ Found Godot at: $path" -ForegroundColor Green
            break
        }
    }
    catch {
        # Continue searching
    }
    
    if (Test-Path $path) {
        $godotPath = $path
        $godotFound = $true
        Write-Host "✅ Found Godot at: $path" -ForegroundColor Green
        break
    }
}

if ($godotFound) {
    Write-Host "Running comprehensive syntax test..." -ForegroundColor Yellow
    
    try {
        # Run the syntax test
        $result = & $godotPath --headless --script test_syntax.gd 2>&1
        
        Write-Host "`n=== GODOT SYNTAX TEST OUTPUT ===" -ForegroundColor Cyan
        Write-Host $result
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "`n🎉 SYNTAX TEST PASSED!" -ForegroundColor Green
            Write-Host "✅ All scripts loaded successfully" -ForegroundColor Green
            Write-Host "✅ All classes can be instantiated" -ForegroundColor Green
            Write-Host "✅ Basic functionality works" -ForegroundColor Green
        } else {
            Write-Host "`n❌ SYNTAX TEST FAILED!" -ForegroundColor Red
            Write-Host "🔧 Critical errors found that need fixing" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "❌ Error running Godot test: $_" -ForegroundColor Red
        Write-Host "Falling back to manual file validation..." -ForegroundColor Yellow
        
        # Manual validation fallback
        Write-Host "`n=== MANUAL FILE VALIDATION ===" -ForegroundColor Cyan
        
        $requiredFiles = @(
            "project.godot",
            "scenes/main/main.tscn",
            "autoload/event_bus.gd",
            "autoload/game_manager.gd",
            "autoload/audio_manager.gd",
            "autoload/settings_manager.gd",
            "scripts/data/models/beat_event.gd",
            "scripts/data/models/audio_data.gd",
            "scripts/data/models/error_event.gd",
            "scripts/data/models/board_state.gd"
        )
        
        $missingFiles = @()
        
        foreach ($file in $requiredFiles) {
            if (Test-Path $file) {
                Write-Host "✅ $file" -ForegroundColor Green
            } else {
                Write-Host "❌ $file" -ForegroundColor Red
                $missingFiles += $file
            }
        }
        
        if ($missingFiles.Count -eq 0) {
            Write-Host "`n✅ All required files exist" -ForegroundColor Green
        } else {
            Write-Host "`n❌ Missing $($missingFiles.Count) files:" -ForegroundColor Red
            foreach ($file in $missingFiles) {
                Write-Host "  - $file" -ForegroundColor Red
            }
        }
    }
} else {
    Write-Host "❌ Godot executable not found!" -ForegroundColor Red
    Write-Host "Please install Godot 4.x or add it to your PATH" -ForegroundColor Yellow
    Write-Host "Falling back to basic file validation..." -ForegroundColor Yellow
    
    # Basic file validation
    Write-Host "`n=== BASIC FILE VALIDATION ===" -ForegroundColor Cyan
    
    $coreFiles = @(
        "project.godot",
        "scenes/main/main.tscn", 
        "autoload/event_bus.gd",
        "autoload/game_manager.gd",
        "autoload/audio_manager.gd",
        "autoload/settings_manager.gd"
    )
    
    $allExist = $true
    
    foreach ($file in $coreFiles) {
        if (Test-Path $file) {
            Write-Host "✅ $file exists" -ForegroundColor Green
        } else {
            Write-Host "❌ $file missing" -ForegroundColor Red
            $allExist = $false
        }
    }
    
    if ($allExist) {
        Write-Host "`n✅ All core files exist - basic structure is complete" -ForegroundColor Green
        Write-Host "⚠️  Cannot verify syntax without Godot - install Godot 4.x for full testing" -ForegroundColor Yellow
    } else {
        Write-Host "`n❌ Missing core files - project structure incomplete" -ForegroundColor Red
    }
}

Write-Host "`n=== TESTING COMPLETE ===" -ForegroundColor Cyan
