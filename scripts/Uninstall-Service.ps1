# ================================================================
# SCRIPT DE DESINSTALACIÓN - IntegradorOptimo
# ================================================================
# Este script desinstala el Servicio de Windows
# ================================================================

# Requiere PowerShell ejecutado como Administrador

Write-Host ""
Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor Red
Write-Host "    DESINSTALACIÓN - INTEGRADOR ÓPTIMO" -ForegroundColor Red
Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor Red
Write-Host ""

# ================================================================
# 1. VERIFICAR PERMISOS DE ADMINISTRADOR
# ================================================================

$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host "? ERROR: Este script debe ejecutarse como Administrador" -ForegroundColor Red
    Write-Host ""
    Write-Host "Para ejecutar como Administrador:" -ForegroundColor Yellow
    Write-Host "1. Haz clic derecho en PowerShell" -ForegroundColor Yellow
    Write-Host "2. Selecciona 'Ejecutar como administrador'" -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host "? Verificación de permisos: OK" -ForegroundColor Green
Write-Host ""

# ================================================================
# 2. CONFIGURACIÓN
# ================================================================

$serviceName = "IntegradorOptimo"
$installPath = "C:\IntegradorOptimo"

Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor Yellow
Write-Host "CONFIGURACIÓN:" -ForegroundColor Yellow
Write-Host "  Servicio: $serviceName" -ForegroundColor White
Write-Host "  Ruta: $installPath" -ForegroundColor White
Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor Yellow
Write-Host ""

Write-Host "??  ADVERTENCIA:" -ForegroundColor Red
Write-Host "Esta operación:" -ForegroundColor Yellow
Write-Host "  - Detendrá el servicio $serviceName" -ForegroundColor White
Write-Host "  - Eliminará el servicio del sistema" -ForegroundColor White
Write-Host "  - Preguntará si deseas eliminar los archivos" -ForegroundColor White
Write-Host ""

$confirm = Read-Host "¿Continuar con la desinstalación? (S/N)"
if ($confirm -ne "S" -and $confirm -ne "s") {
    Write-Host "Desinstalación cancelada." -ForegroundColor Yellow
    exit 0
}

Write-Host ""

# ================================================================
# 3. VERIFICAR SI EL SERVICIO EXISTE
# ================================================================

Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host "PASO 1: Verificar servicio" -ForegroundColor Yellow
Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

$service = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if (-not $service) {
    Write-Host "??  El servicio '$serviceName' no existe" -ForegroundColor Cyan
    Write-Host ""
    
    # Preguntar si desea eliminar archivos
    if (Test-Path $installPath) {
        $deleteFiles = Read-Host "¿Deseas eliminar los archivos en $installPath? (S/N)"
        if ($deleteFiles -eq "S" -or $deleteFiles -eq "s") {
            Write-Host "Eliminando archivos..." -ForegroundColor Yellow
            Remove-Item -Path $installPath -Recurse -Force
            Write-Host "? Archivos eliminados" -ForegroundColor Green
        } else {
            Write-Host "??  Archivos conservados en: $installPath" -ForegroundColor Cyan
        }
    }
    
    Write-Host ""
    Write-Host "? Desinstalación completada" -ForegroundColor Green
    Read-Host "Presiona Enter para salir"
    exit 0
}

Write-Host "??  Servicio encontrado" -ForegroundColor Cyan
Write-Host "   Estado: $($service.Status)" -ForegroundColor White
Write-Host ""

# ================================================================
# 4. DETENER EL SERVICIO
# ================================================================

Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host "PASO 2: Detener servicio" -ForegroundColor Yellow
Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

if ($service.Status -eq 'Running') {
    Write-Host "Deteniendo servicio..." -ForegroundColor Yellow
    
    try {
        Stop-Service -Name $serviceName -Force -ErrorAction Stop
        Start-Sleep -Seconds 3
        Write-Host "? Servicio detenido" -ForegroundColor Green
    } catch {
        Write-Host "??  No se pudo detener el servicio automáticamente" -ForegroundColor Yellow
        Write-Host "   Intentando con sc.exe..." -ForegroundColor Yellow
        
        sc.exe stop $serviceName | Out-Null
        Start-Sleep -Seconds 3
        
        $service = Get-Service -Name $serviceName
        if ($service.Status -ne 'Running') {
            Write-Host "? Servicio detenido" -ForegroundColor Green
        } else {
            Write-Host "? ERROR: No se pudo detener el servicio" -ForegroundColor Red
            Write-Host "   Detén manualmente el servicio antes de continuar" -ForegroundColor Yellow
            Read-Host "Presiona Enter para salir"
            exit 1
        }
    }
} else {
    Write-Host "??  El servicio ya está detenido" -ForegroundColor Cyan
}

Write-Host ""

# ================================================================
# 5. ELIMINAR EL SERVICIO
# ================================================================

Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host "PASO 3: Eliminar servicio" -ForegroundColor Yellow
Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Eliminando servicio..." -ForegroundColor Yellow

$deleteResult = sc.exe delete $serviceName 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "? ERROR: Falló la eliminación del servicio" -ForegroundColor Red
    Write-Host $deleteResult -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

Start-Sleep -Seconds 2
Write-Host "? Servicio eliminado del sistema" -ForegroundColor Green
Write-Host ""

# ================================================================
# 6. PREGUNTAR POR ELIMINACIÓN DE ARCHIVOS
# ================================================================

Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host "PASO 4: Archivos de instalación" -ForegroundColor Yellow
Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

if (Test-Path $installPath) {
    Write-Host "Se encontraron archivos en: $installPath" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Contenido:" -ForegroundColor Yellow
    Get-ChildItem -Path $installPath -Directory | ForEach-Object {
        Write-Host "  ?? $($_.Name)" -ForegroundColor White
    }
    Get-ChildItem -Path $installPath -File -Filter "*.json" | ForEach-Object {
        Write-Host "  ?? $($_.Name)" -ForegroundColor White
    }
    Get-ChildItem -Path $installPath -File -Filter "*.exe" | ForEach-Object {
        Write-Host "  ??  $($_.Name)" -ForegroundColor White
    }
    
    Write-Host ""
    Write-Host "??  IMPORTANTE:" -ForegroundColor Yellow
    Write-Host "  - Los logs históricos se perderán" -ForegroundColor White
    Write-Host "  - El archivo appsettings.json se perderá" -ForegroundColor White
    Write-Host ""
    
    $deleteFiles = Read-Host "¿Deseas eliminar TODOS los archivos? (S/N)"
    
    if ($deleteFiles -eq "S" -or $deleteFiles -eq "s") {
        Write-Host ""
        Write-Host "Eliminando archivos..." -ForegroundColor Yellow
        
        try {
            Remove-Item -Path $installPath -Recurse -Force -ErrorAction Stop
            Write-Host "? Archivos eliminados" -ForegroundColor Green
        } catch {
            Write-Host "? ERROR: No se pudieron eliminar algunos archivos" -ForegroundColor Red
            Write-Host "   Algunos archivos pueden estar en uso" -ForegroundColor Yellow
            Write-Host "   Intenta reiniciar Windows y eliminar manualmente:" -ForegroundColor Yellow
            Write-Host "   $installPath" -ForegroundColor White
        }
    } else {
        Write-Host ""
        Write-Host "??  Archivos conservados en: $installPath" -ForegroundColor Cyan
        Write-Host ""
        Write-Host "Puedes:" -ForegroundColor Yellow
        Write-Host "  - Conservar el appsettings.json para futuras instalaciones" -ForegroundColor White
        Write-Host "  - Respaldar los logs si lo necesitas" -ForegroundColor White
        Write-Host "  - Eliminar manualmente cuando lo desees" -ForegroundColor White
    }
} else {
    Write-Host "??  No se encontraron archivos de instalación" -ForegroundColor Cyan
}

Write-Host ""

# ================================================================
# 7. PREGUNTAR POR ELIMINACIÓN DE BASE DE DATOS
# ================================================================

Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host "PASO 5: Base de datos IntegradorDB" -ForegroundColor Yellow
Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

Write-Host "??  IMPORTANTE: Base de datos IntegradorDB" -ForegroundColor Yellow
Write-Host ""
Write-Host "La base de datos 'IntegradorDB' contiene:" -ForegroundColor Cyan
Write-Host "  - Configuración del sistema" -ForegroundColor White
Write-Host "  - Historial de ejecuciones" -ForegroundColor White
Write-Host "  - Estadísticas de performance" -ForegroundColor White
Write-Host ""
Write-Host "Esta base de datos NO se eliminará automáticamente." -ForegroundColor Yellow
Write-Host ""

$deleteDB = Read-Host "¿Deseas ver el script para eliminar la BD? (S/N)"

if ($deleteDB -eq "S" -or $deleteDB -eq "s") {
    Write-Host ""
    Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor Cyan
    Write-Host "SCRIPT PARA ELIMINAR IntegradorDB (OPCIONAL)" -ForegroundColor Cyan
    Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "-- Ejecuta este script en SQL Server Management Studio (SSMS)" -ForegroundColor Yellow
    Write-Host "-- Solo si deseas eliminar completamente la configuración" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "USE master;" -ForegroundColor White
    Write-Host "GO" -ForegroundColor White
    Write-Host "" -ForegroundColor White
    Write-Host "-- Cerrar conexiones activas" -ForegroundColor Green
    Write-Host "ALTER DATABASE IntegradorDB SET SINGLE_USER WITH ROLLBACK IMMEDIATE;" -ForegroundColor White
    Write-Host "GO" -ForegroundColor White
    Write-Host "" -ForegroundColor White
    Write-Host "-- Eliminar base de datos" -ForegroundColor Green
    Write-Host "DROP DATABASE IntegradorDB;" -ForegroundColor White
    Write-Host "GO" -ForegroundColor White
    Write-Host ""
    Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor Cyan
    Write-Host ""
}

# ================================================================
# 8. RESUMEN FINAL
# ================================================================

Write-Host ""
Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor Green
Write-Host "           ? DESINSTALACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor Green
Write-Host ""
Write-Host "?? Resumen:" -ForegroundColor Cyan
Write-Host "   ? Servicio '$serviceName' detenido" -ForegroundColor Green
Write-Host "   ? Servicio eliminado del sistema" -ForegroundColor Green

if (-not (Test-Path $installPath)) {
    Write-Host "   ? Archivos eliminados de $installPath" -ForegroundColor Green
} else {
    Write-Host "   ??  Archivos conservados en $installPath" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "?? Verificación:" -ForegroundColor Cyan
Write-Host "   Verifica que el servicio no exista:" -ForegroundColor White
Write-Host "   sc.exe query $serviceName" -ForegroundColor Gray
Write-Host "   (Debe mostrar: ERROR 1060 - El servicio especificado no existe)" -ForegroundColor Gray
Write-Host ""

if (Test-Path $installPath) {
    Write-Host "?? Archivos conservados:" -ForegroundColor Cyan
    Write-Host "   $installPath" -ForegroundColor White
    Write-Host ""
    Write-Host "   Puedes:" -ForegroundColor Yellow
    Write-Host "   - Conservarlos para futuras instalaciones" -ForegroundColor White
    Write-Host "   - Eliminarlos manualmente cuando lo desees" -ForegroundColor White
    Write-Host ""
}

Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor Green
Write-Host ""

Read-Host "Presiona Enter para salir"
