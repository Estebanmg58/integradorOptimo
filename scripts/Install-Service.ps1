# ================================================================
# SCRIPT DE INSTALACIÓN AUTOMÁTICA - IntegradorOptimo
# ================================================================
# Este script automatiza la instalación como Servicio de Windows
# ================================================================

# Requiere PowerShell ejecutado como Administrador

Write-Host ""
Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "    INSTALACIÓN AUTOMÁTICA - INTEGRADOR ÓPTIMO" -ForegroundColor Cyan
Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor Cyan
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
# 2. VERIFICAR .NET 8 RUNTIME
# ================================================================

Write-Host "Verificando .NET 8 Runtime..." -ForegroundColor Yellow

try {
    $dotnetVersion = dotnet --version
    Write-Host "? .NET Runtime instalado: $dotnetVersion" -ForegroundColor Green
} catch {
    Write-Host "? .NET 8 Runtime NO está instalado" -ForegroundColor Red
    Write-Host ""
    Write-Host "Descarga e instala .NET 8 Runtime desde:" -ForegroundColor Yellow
    Write-Host "https://dotnet.microsoft.com/download/dotnet/8.0/runtime" -ForegroundColor Cyan
    Write-Host ""
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host ""

# ================================================================
# 3. CONFIGURAR RUTAS
# ================================================================

# Ruta del proyecto (ajustar si es necesario)
$projectRoot = "C:\integradorOptimo"
$publishPath = "C:\IntegradorOptimo"
$serviceName = "IntegradorOptimo"
$serviceDisplayName = "Integrador Óptimo - FondoSuma"
$serviceDescription = "Servicio de sincronización de datos entre ERP y FondoSuma"

Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "CONFIGURACIÓN:" -ForegroundColor Cyan
Write-Host "  Proyecto: $projectRoot" -ForegroundColor White
Write-Host "  Instalación: $publishPath" -ForegroundColor White
Write-Host "  Servicio: $serviceName" -ForegroundColor White
Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host ""

$confirm = Read-Host "¿Continuar con la instalación? (S/N)"
if ($confirm -ne "S" -and $confirm -ne "s") {
    Write-Host "Instalación cancelada." -ForegroundColor Yellow
    exit 0
}

Write-Host ""

# ================================================================
# 4. COMPILAR Y PUBLICAR LA APLICACIÓN
# ================================================================

Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host "PASO 1: Compilar y publicar aplicación" -ForegroundColor Yellow
Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

if (-not (Test-Path $projectRoot)) {
    Write-Host "? ERROR: No se encuentra el proyecto en: $projectRoot" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

Set-Location $projectRoot

Write-Host "Publicando aplicación..." -ForegroundColor Yellow

$publishResult = dotnet publish src/Integrador.Worker/Integrador.Worker.csproj `
    -c Release `
    -r win-x64 `
    --self-contained false `
    -o $publishPath `
    2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "? ERROR: Falló la publicación de la aplicación" -ForegroundColor Red
    Write-Host $publishResult -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host "? Aplicación publicada en: $publishPath" -ForegroundColor Green
Write-Host ""

# ================================================================
# 5. VERIFICAR appsettings.json
# ================================================================

Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host "PASO 2: Verificar configuración" -ForegroundColor Yellow
Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

$appsettingsPath = Join-Path $publishPath "appsettings.json"

if (-not (Test-Path $appsettingsPath)) {
    Write-Host "??  ADVERTENCIA: No se encuentra appsettings.json" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Por favor:" -ForegroundColor Yellow
    Write-Host "1. Copia appsettings.TEMPLATE.json a appsettings.json" -ForegroundColor White
    Write-Host "2. Edita appsettings.json con tus credenciales" -ForegroundColor White
    Write-Host "3. Ejecuta nuevamente este script" -ForegroundColor White
    Write-Host ""
    
    # Copiar template si existe
    $templatePath = Join-Path $publishPath "appsettings.TEMPLATE.json"
    if (Test-Path $templatePath) {
        Copy-Item $templatePath $appsettingsPath
        Write-Host "? appsettings.json creado desde template" -ForegroundColor Green
        Write-Host ""
        Write-Host "??  IMPORTANTE: Edita $appsettingsPath con tus credenciales antes de continuar" -ForegroundColor Yellow
        Write-Host ""
        
        $continue = Read-Host "¿Ya editaste appsettings.json? (S/N)"
        if ($continue -ne "S" -and $continue -ne "s") {
            Write-Host "Instalación pausada. Edita appsettings.json y ejecuta nuevamente." -ForegroundColor Yellow
            exit 0
        }
    } else {
        Read-Host "Presiona Enter para salir"
        exit 1
    }
}

Write-Host "? appsettings.json encontrado" -ForegroundColor Green
Write-Host ""

# ================================================================
# 6. DETENER Y ELIMINAR SERVICIO EXISTENTE (SI EXISTE)
# ================================================================

Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host "PASO 3: Verificar servicio existente" -ForegroundColor Yellow
Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

$existingService = Get-Service -Name $serviceName -ErrorAction SilentlyContinue

if ($existingService) {
    Write-Host "??  Servicio existente encontrado: $serviceName" -ForegroundColor Yellow
    
    # Detener el servicio si está ejecutándose
    if ($existingService.Status -eq 'Running') {
        Write-Host "Deteniendo servicio..." -ForegroundColor Yellow
        Stop-Service -Name $serviceName -Force
        Start-Sleep -Seconds 2
        Write-Host "? Servicio detenido" -ForegroundColor Green
    }
    
    # Eliminar el servicio
    Write-Host "Eliminando servicio existente..." -ForegroundColor Yellow
    sc.exe delete $serviceName | Out-Null
    Start-Sleep -Seconds 2
    Write-Host "? Servicio existente eliminado" -ForegroundColor Green
} else {
    Write-Host "??  No hay servicio existente" -ForegroundColor Cyan
}

Write-Host ""

# ================================================================
# 7. CREAR E INSTALAR EL SERVICIO
# ================================================================

Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host "PASO 4: Instalar servicio" -ForegroundColor Yellow
Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

$exePath = Join-Path $publishPath "Integrador.Worker.exe"

if (-not (Test-Path $exePath)) {
    Write-Host "? ERROR: No se encuentra el ejecutable en: $exePath" -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host "Creando servicio de Windows..." -ForegroundColor Yellow

# Crear el servicio
$createResult = sc.exe create $serviceName `
    binPath= $exePath `
    start= auto `
    DisplayName= $serviceDisplayName `
    2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "? ERROR: Falló la creación del servicio" -ForegroundColor Red
    Write-Host $createResult -ForegroundColor Red
    Read-Host "Presiona Enter para salir"
    exit 1
}

Write-Host "? Servicio creado" -ForegroundColor Green

# Configurar descripción
sc.exe description $serviceName $serviceDescription | Out-Null
Write-Host "? Descripción configurada" -ForegroundColor Green

# Configurar reinicio automático en caso de fallo
sc.exe failure $serviceName reset= 86400 actions= restart/60000/restart/60000/restart/60000 | Out-Null
Write-Host "? Reinicio automático configurado" -ForegroundColor Green

Write-Host ""

# ================================================================
# 8. INICIAR EL SERVICIO
# ================================================================

Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host "PASO 5: Iniciar servicio" -ForegroundColor Yellow
Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Iniciando servicio..." -ForegroundColor Yellow
Start-Sleep -Seconds 2

$startResult = sc.exe start $serviceName 2>&1

if ($LASTEXITCODE -ne 0) {
    Write-Host "??  ADVERTENCIA: El servicio no pudo iniciarse automáticamente" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Esto puede ser normal en la primera instalación." -ForegroundColor Yellow
    Write-Host "El servicio se iniciará automáticamente en el próximo reinicio." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Para iniciar manualmente:" -ForegroundColor Cyan
    Write-Host "  sc.exe start $serviceName" -ForegroundColor White
    Write-Host ""
} else {
    Start-Sleep -Seconds 3
    
    $service = Get-Service -Name $serviceName
    
    if ($service.Status -eq 'Running') {
        Write-Host "? Servicio iniciado exitosamente" -ForegroundColor Green
    } else {
        Write-Host "??  Servicio instalado pero no está en ejecución" -ForegroundColor Yellow
        Write-Host "   Estado: $($service.Status)" -ForegroundColor Yellow
    }
}

Write-Host ""

# ================================================================
# 9. CREAR CARPETA DE LOGS
# ================================================================

$logsPath = Join-Path $publishPath "logs"
if (-not (Test-Path $logsPath)) {
    New-Item -ItemType Directory -Path $logsPath -Force | Out-Null
    Write-Host "? Carpeta de logs creada: $logsPath" -ForegroundColor Green
} else {
    Write-Host "??  Carpeta de logs ya existe" -ForegroundColor Cyan
}

Write-Host ""

# ================================================================
# 10. RESUMEN FINAL
# ================================================================

Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor Green
Write-Host "             ? INSTALACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor Green
Write-Host ""
Write-Host "?? Ubicación:" -ForegroundColor Cyan
Write-Host "   $publishPath" -ForegroundColor White
Write-Host ""
Write-Host "?? Servicio:" -ForegroundColor Cyan
Write-Host "   Nombre: $serviceName" -ForegroundColor White
Write-Host "   Estado: $((Get-Service -Name $serviceName).Status)" -ForegroundColor White
Write-Host ""
Write-Host "?? Archivos importantes:" -ForegroundColor Cyan
Write-Host "   Configuración: $publishPath\appsettings.json" -ForegroundColor White
Write-Host "   Logs: $publishPath\logs\" -ForegroundColor White
Write-Host ""
Write-Host "?? Próximos pasos:" -ForegroundColor Cyan
Write-Host "   1. Verificar logs:" -ForegroundColor White
Write-Host "      Get-Content $publishPath\logs\log-*.txt -Tail 50" -ForegroundColor Gray
Write-Host ""
Write-Host "   2. Ver estado del servicio:" -ForegroundColor White
Write-Host "      sc.exe query $serviceName" -ForegroundColor Gray
Write-Host ""
Write-Host "   3. Configurar horario en SQL Server:" -ForegroundColor White
Write-Host "      USE IntegradorDB;" -ForegroundColor Gray
Write-Host "      EXEC sp_ViewCurrentConfiguration;" -ForegroundColor Gray
Write-Host ""
Write-Host "   4. Ajustar horario (opcional):" -ForegroundColor White
Write-Host "      EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 2 * * *';" -ForegroundColor Gray
Write-Host ""
Write-Host "?? Comandos útiles:" -ForegroundColor Cyan
Write-Host "   Iniciar:   sc.exe start $serviceName" -ForegroundColor White
Write-Host "   Detener:   sc.exe stop $serviceName" -ForegroundColor White
Write-Host "   Reiniciar: sc.exe stop $serviceName; sc.exe start $serviceName" -ForegroundColor White
Write-Host "   Estado:    sc.exe query $serviceName" -ForegroundColor White
Write-Host ""
Write-Host "???????????????????????????????????????????????????????????" -ForegroundColor Green
Write-Host ""

# Esperar antes de salir
Write-Host "Presiona Enter para ver los logs en tiempo real (Ctrl+C para salir)..." -ForegroundColor Yellow
Read-Host

# Mostrar logs en tiempo real
Get-Content "$publishPath\logs\log-*.txt" -Tail 50 -Wait
