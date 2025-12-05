# ================================================
# Script de Instalación - IntegradorOptimo
# Windows Service Installer
# ================================================
# IMPORTANTE: Ejecutar como Administrador
# ================================================

param(
    [string]$Action = "install"
)

$ServiceName = "IntegradorOptimo"
$DisplayName = "Integrador Optimo - Sincronizador ERP"
$Description = "Worker Service para sincronización automática de datos ERP a API FondoSuma"
$InstallPath = "C:\IntegradorOptimo"
$ExePath = "$InstallPath\Integrador.Worker.exe"
$ProjectPath = "src\Integrador.Worker\Integrador.Worker.csproj"

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Test-Administrator {
    $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
    return $currentUser.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-Service {
    Write-ColorOutput Green "========================================="
    Write-ColorOutput Green "?? INSTALACIÓN DE INTEGRADOR ÓPTIMO"
    Write-ColorOutput Green "========================================="
    
    # Verificar privilegios de administrador
    if (-not (Test-Administrator)) {
        Write-ColorOutput Red "? ERROR: Debes ejecutar este script como Administrador"
        Write-ColorOutput Yellow "Haz clic derecho en PowerShell y selecciona 'Ejecutar como Administrador'"
        exit 1
    }
    
    # Detener servicio si existe
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($service) {
        Write-ColorOutput Yellow "??  Servicio existente detectado, deteniendo..."
        Stop-Service -Name $ServiceName -Force
        Start-Sleep -Seconds 2
        
        Write-ColorOutput Yellow "???  Eliminando servicio anterior..."
        sc.exe delete $ServiceName
        Start-Sleep -Seconds 2
    }
    
    # Compilar proyecto en Release
    Write-ColorOutput Cyan "?? Compilando proyecto en modo Release..."
    dotnet build $ProjectPath -c Release
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput Red "? Error al compilar el proyecto"
        exit 1
    }
    
    # Publicar aplicación
    Write-ColorOutput Cyan "?? Publicando aplicación en $InstallPath..."
    dotnet publish $ProjectPath -c Release -o $InstallPath --self-contained false
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput Red "? Error al publicar el proyecto"
        exit 1
    }
    
    # Verificar que el ejecutable existe
    if (-not (Test-Path $ExePath)) {
        Write-ColorOutput Red "? Error: No se encontró el ejecutable en $ExePath"
        exit 1
    }
    
    # Crear directorio de logs
    $LogPath = "C:\Logs\IntegradorOptimo"
    if (-not (Test-Path $LogPath)) {
        Write-ColorOutput Cyan "?? Creando directorio de logs: $LogPath"
        New-Item -ItemType Directory -Path $LogPath -Force | Out-Null
    }
    
    # Crear servicio de Windows
    Write-ColorOutput Cyan "??  Registrando servicio de Windows..."
    sc.exe create $ServiceName binPath= $ExePath start= auto DisplayName= $DisplayName
    sc.exe description $ServiceName $Description
    
    if ($LASTEXITCODE -ne 0) {
        Write-ColorOutput Red "? Error al crear el servicio"
        exit 1
    }
    
    # Configurar recovery (reinicio automático en caso de fallo)
    Write-ColorOutput Cyan "?? Configurando reinicio automático en caso de fallo..."
    sc.exe failure $ServiceName reset= 86400 actions= restart/60000/restart/60000/restart/60000
    
    # Iniciar servicio
    Write-ColorOutput Cyan "??  Iniciando servicio..."
    Start-Service -Name $ServiceName
    Start-Sleep -Seconds 3
    
    # Verificar estado
    $service = Get-Service -Name $ServiceName
    if ($service.Status -eq "Running") {
        Write-ColorOutput Green "========================================="
        Write-ColorOutput Green "? INSTALACIÓN COMPLETADA EXITOSAMENTE"
        Write-ColorOutput Green "========================================="
        Write-ColorOutput White ""
        Write-ColorOutput White "?? Estado del servicio:"
        Write-ColorOutput White "   Nombre: $ServiceName"
        Write-ColorOutput White "   Estado: $($service.Status)"
        Write-ColorOutput White "   Inicio: Automático"
        Write-ColorOutput White "   Ruta: $ExePath"
        Write-ColorOutput White ""
        Write-ColorOutput White "?? Logs disponibles en: $LogPath"
        Write-ColorOutput White ""
        Write-ColorOutput Cyan "?? Comandos útiles:"
        Write-ColorOutput White "   Ver estado:   sc.exe query $ServiceName"
        Write-ColorOutput White "   Detener:      Stop-Service -Name $ServiceName"
        Write-ColorOutput White "   Iniciar:      Start-Service -Name $ServiceName"
        Write-ColorOutput White "   Ver logs:     Get-Content $LogPath\log-*.txt -Tail 50 -Wait"
    } else {
        Write-ColorOutput Yellow "??  El servicio se instaló pero no está ejecutándose"
        Write-ColorOutput Yellow "   Estado actual: $($service.Status)"
        Write-ColorOutput Yellow "   Revisa los logs para más información"
    }
}

function Uninstall-Service {
    Write-ColorOutput Yellow "========================================="
    Write-ColorOutput Yellow "???  DESINSTALACIÓN DE INTEGRADOR ÓPTIMO"
    Write-ColorOutput Yellow "========================================="
    
    if (-not (Test-Administrator)) {
        Write-ColorOutput Red "? ERROR: Debes ejecutar este script como Administrador"
        exit 1
    }
    
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    if ($service) {
        Write-ColorOutput Cyan "??  Deteniendo servicio..."
        Stop-Service -Name $ServiceName -Force
        Start-Sleep -Seconds 2
        
        Write-ColorOutput Cyan "???  Eliminando servicio..."
        sc.exe delete $ServiceName
        
        Write-ColorOutput Green "? Servicio eliminado exitosamente"
    } else {
        Write-ColorOutput Yellow "??  El servicio no está instalado"
    }
    
    Write-ColorOutput Cyan ""
    Write-ColorOutput Cyan "?? Nota: Los archivos en $InstallPath no fueron eliminados"
    Write-ColorOutput Cyan "   Puedes eliminarlos manualmente si lo deseas"
}

function Get-ServiceStatus {
    $service = Get-Service -Name $ServiceName -ErrorAction SilentlyContinue
    
    Write-ColorOutput Cyan "========================================="
    Write-ColorOutput Cyan "?? ESTADO DE INTEGRADOR ÓPTIMO"
    Write-ColorOutput Cyan "========================================="
    
    if ($service) {
        $statusColor = if ($service.Status -eq "Running") { "Green" } else { "Yellow" }
        
        Write-ColorOutput White "Nombre:        $ServiceName"
        Write-ColorOutput $statusColor "Estado:        $($service.Status)"
        Write-ColorOutput White "Tipo Inicio:   $($service.StartType)"
        Write-ColorOutput White "Display Name:  $($service.DisplayName)"
        
        if (Test-Path $ExePath) {
            $fileInfo = Get-Item $ExePath
            Write-ColorOutput White "Ruta:          $ExePath"
            Write-ColorOutput White "Última mod.:   $($fileInfo.LastWriteTime)"
        }
        
        # Mostrar últimas líneas del log
        $LogPath = "C:\Logs\IntegradorOptimo"
        $latestLog = Get-ChildItem -Path $LogPath -Filter "log-*.txt" -ErrorAction SilentlyContinue | 
                     Sort-Object LastWriteTime -Descending | 
                     Select-Object -First 1
        
        if ($latestLog) {
            Write-ColorOutput Cyan "`n?? Últimas 10 líneas del log ($($latestLog.Name)):"
            Write-ColorOutput White "?????????????????????????????????????????"
            Get-Content $latestLog.FullName -Tail 10 | ForEach-Object {
                Write-ColorOutput White $_
            }
        }
    } else {
        Write-ColorOutput Red "? El servicio no está instalado"
    }
}

function Show-Logs {
    $LogPath = "C:\Logs\IntegradorOptimo"
    
    if (-not (Test-Path $LogPath)) {
        Write-ColorOutput Red "? No se encontró el directorio de logs: $LogPath"
        exit 1
    }
    
    $latestLog = Get-ChildItem -Path $LogPath -Filter "log-*.txt" | 
                 Sort-Object LastWriteTime -Descending | 
                 Select-Object -First 1
    
    if ($latestLog) {
        Write-ColorOutput Green "?? Mostrando log en tiempo real: $($latestLog.Name)"
        Write-ColorOutput Green "   Presiona Ctrl+C para detener"
        Write-ColorOutput White "?????????????????????????????????????????"
        Get-Content $latestLog.FullName -Tail 50 -Wait
    } else {
        Write-ColorOutput Red "? No se encontraron archivos de log"
    }
}

# ================================================
# MENÚ PRINCIPAL
# ================================================

switch ($Action.ToLower()) {
    "install" {
        Install-Service
    }
    "uninstall" {
        Uninstall-Service
    }
    "status" {
        Get-ServiceStatus
    }
    "logs" {
        Show-Logs
    }
    "restart" {
        Write-ColorOutput Cyan "?? Reiniciando servicio..."
        Restart-Service -Name $ServiceName -Force
        Start-Sleep -Seconds 3
        Get-ServiceStatus
    }
    "start" {
        Write-ColorOutput Cyan "??  Iniciando servicio..."
        Start-Service -Name $ServiceName
        Start-Sleep -Seconds 2
        Get-ServiceStatus
    }
    "stop" {
        Write-ColorOutput Cyan "??  Deteniendo servicio..."
        Stop-Service -Name $ServiceName -Force
        Start-Sleep -Seconds 2
        Get-ServiceStatus
    }
    default {
        Write-ColorOutput White "========================================="
        Write-ColorOutput White "IntegradorOptimo - Gestión de Servicio"
        Write-ColorOutput White "========================================="
        Write-ColorOutput White ""
        Write-ColorOutput White "Uso: .\Install-Service.ps1 -Action <acción>"
        Write-ColorOutput White ""
        Write-ColorOutput White "Acciones disponibles:"
        Write-ColorOutput Cyan "  install     " -NoNewline; Write-ColorOutput White "Instalar y configurar el servicio"
        Write-ColorOutput Cyan "  uninstall   " -NoNewline; Write-ColorOutput White "Desinstalar el servicio"
        Write-ColorOutput Cyan "  status      " -NoNewline; Write-ColorOutput White "Ver estado del servicio"
        Write-ColorOutput Cyan "  start       " -NoNewline; Write-ColorOutput White "Iniciar el servicio"
        Write-ColorOutput Cyan "  stop        " -NoNewline; Write-ColorOutput White "Detener el servicio"
        Write-ColorOutput Cyan "  restart     " -NoNewline; Write-ColorOutput White "Reiniciar el servicio"
        Write-ColorOutput Cyan "  logs        " -NoNewline; Write-ColorOutput White "Ver logs en tiempo real"
        Write-ColorOutput White ""
        Write-ColorOutput Yellow "Ejemplos:"
        Write-ColorOutput White "  .\Install-Service.ps1 -Action install"
        Write-ColorOutput White "  .\Install-Service.ps1 -Action status"
        Write-ColorOutput White "  .\Install-Service.ps1 -Action logs"
    }
}
