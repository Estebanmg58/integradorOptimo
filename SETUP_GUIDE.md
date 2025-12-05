# ?? GUÍA RÁPIDA DE INSTALACIÓN Y CONFIGURACIÓN

## ?? TABLA DE CONTENIDOS

1. [Pre-requisitos](#pre-requisitos)
2. [Instalación Paso a Paso](#instalación-paso-a-paso)
3. [Configuración de Base de Datos](#configuración-de-base-de-datos)
4. [Configuración de la Aplicación](#configuración-de-la-aplicación)
5. [Configurar Horarios](#configurar-horarios)
6. [Instalación como Servicio](#instalación-como-servicio)
7. [Monitoreo](#monitoreo)
8. [Troubleshooting](#troubleshooting)

---

## ?? PRE-REQUISITOS

### Software Necesario

- ? Windows Server 2016+ o Windows 10/11 Pro
- ? .NET 8 Runtime: [Descargar aquí](https://dotnet.microsoft.com/download/dotnet/8.0/runtime)
- ? SQL Server 2016+ (acceso al ERP y para IntegradorDB)
- ? SQL Server Management Studio (SSMS)
- ? PowerShell 5.1+

### Permisos Necesarios

**En Windows:**
- ? Administrador local (para instalar como servicio)

**En SQL Server (ERP):**
- ? `SELECT` en tablas: `genAsociados`, `genProductos`, `genMovimiento`, `admTasas`, `admEntidades`
- ? `EXECUTE` en SP: `ERP_SPConsultaDta`

**En SQL Server (Configuración):**
- ? `CREATE DATABASE` (para crear IntegradorDB)
- ? `SELECT`, `UPDATE` en tabla: `IntegrationSettings`

### Información Requerida

- ?? Servidor SQL del ERP (nombre/IP y puerto)
- ?? Nombre de la base de datos del ERP
- ?? Usuario y contraseña de SQL Server
- ?? URL de la API de FondoSuma
- ?? API Key de autenticación

---

## ?? INSTALACIÓN PASO A PASO

### 1. Descargar el Código

```powershell
# Opción A: Clonar desde Git
cd C:\
git clone https://github.com/Estebanmg58/integradorOptimo.git
cd integradorOptimo

# Opción B: Descargar ZIP y extraer
# Descargar desde: https://github.com/Estebanmg58/integradorOptimo/archive/refs/heads/main.zip
# Extraer en C:\integradorOptimo
```

### 2. Verificar .NET 8

```powershell
dotnet --version
# Debe mostrar: 8.0.x
```

Si no está instalado:
```powershell
# Descargar e instalar .NET 8 Runtime
# https://dotnet.microsoft.com/download/dotnet/8.0/runtime
```

---

## ??? CONFIGURACIÓN DE BASE DE DATOS

### 1. Crear Base de Datos de Configuración

Abre **SQL Server Management Studio (SSMS)** y ejecuta:

```sql
-- Paso 1: Crear IntegradorDB y tablas
-- Ejecutar: scripts/01_CreateDatabase.sql
```

Este script creará:
- ? Base de datos `IntegradorDB`
- ? Tabla `IntegrationSettings` (configuración)
- ? Tabla `IntegrationExecutionHistory` (historial)
- ? Stored Procedures de configuración
- ? Configuración inicial

### 2. Verificar Instalación

```sql
USE IntegradorDB;

-- Ver configuración inicial
EXEC sp_ViewCurrentConfiguration;

-- Debe mostrar:
-- ScheduleCron: 0 2 * * * (2 AM diariamente)
-- BatchSize: 500
-- Todas las entidades activas
```

### 3. Verificar SP del ERP

```sql
USE TuBaseDatosERP; -- Reemplaza con tu BD

-- Verificar que existe el SP
SELECT * FROM sys.procedures WHERE name = 'ERP_SPConsultaDta';

-- Probar el SP
EXEC ERP_SPConsultaDta @TipoConsulta = 1, @CodigoProducto = NULL, @Consecutivo = NULL;
-- Debe retornar asociados
```

Si el SP no existe o falta el `@TipoConsulta = 6` para movimientos, consulta el archivo `IMPORTANT_SP_ADJUSTMENTS.md`.

---

## ?? CONFIGURACIÓN DE LA APLICACIÓN

### 1. Configurar appsettings.json

Copia el template y edítalo:

```powershell
cd C:\integradorOptimo\src\Integrador.Worker
copy appsettings.TEMPLATE.json appsettings.json
notepad appsettings.json
```

Edita las siguientes secciones:

#### A. Conexión al ERP

```json
"ConnectionStrings": {
  "ErpDatabase": "Server=TU_SERVIDOR;Database=TuBD_ERP;User Id=usuario;Password=password;TrustServerCertificate=true;"
}
```

**Ejemplo real:**
```json
"ErpDatabase": "Server=192.168.1.50,1433;Database=CooperativaDB;User Id=integrador_user;Password=IntP@ss2024!;TrustServerCertificate=true;Connection Timeout=120;"
```

#### B. Conexión a IntegradorDB

```json
"DestinationDatabase": "Server=TU_SERVIDOR;Database=IntegradorDB;User Id=usuario;Password=password;TrustServerCertificate=true;"
```

**Ejemplo real (mismo servidor):**
```json
"DestinationDatabase": "Server=192.168.1.50,1433;Database=IntegradorDB;User Id=integrador_user;Password=IntP@ss2024!;TrustServerCertificate=true;"
```

#### C. Configuración de la API

```json
"ApiSettings": {
  "BaseUrl": "https://api.fondosuma.com",
  "ApiKey": "TU_API_KEY_REAL"
}
```

**Ejemplo real:**
```json
"ApiSettings": {
  "BaseUrl": "https://api.fondosuma.com",
  "ApiKey": "xK9#mP2$vL8@qR5&nT3"
}
```

### 2. Compilar la Aplicación

```powershell
cd C:\integradorOptimo
dotnet build -c Release
```

Debe mostrar:
```
Build succeeded in X.Xs
```

### 3. Probar en Modo Debug

```powershell
cd src\Integrador.Worker
dotnet run
```

Verifica los logs:
```
?? Integrador Óptimo iniciado - Servicio de Windows activo
?? Próxima ejecución programada: 2024-12-20 02:00:00
```

Si todo está bien, presiona `Ctrl+C` para detener.

---

## ?? CONFIGURAR HORARIOS

### Scripts Rápidos

Abre SSMS y ejecuta:

```sql
USE IntegradorDB;

-- Ver configuración actual
EXEC sp_ViewCurrentConfiguration;

-- ============================================
-- HORARIOS COMUNES
-- ============================================

-- Diario a las 2:00 AM (RECOMENDADO PRODUCCIÓN)
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 2 * * *';

-- Diario a las 3:00 AM
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 3 * * *';

-- Cada 4 horas
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 */4 * * *';

-- Cada 30 minutos (PRUEBAS)
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '*/30 * * * *';

-- Cada 15 minutos (PRUEBAS)
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '*/15 * * * *';

-- Cada 5 minutos (DESARROLLO)
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '*/5 * * * *';

-- Cada 1 minuto (SOLO DEBUG)
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '*/1 * * * *';

-- ============================================
-- HORARIOS ESPECÍFICOS
-- ============================================

-- Lunes a Viernes a las 8:00 AM
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 8 * * 1-5';

-- Domingos a las 11:00 PM
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 23 * * 0';

-- Primer día de cada mes a medianoche
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 0 1 * *';

-- Ver nueva configuración
EXEC sp_ViewCurrentConfiguration;
```

### Referencia de Cron Expressions

| Expression | Descripción |
|------------|-------------|
| `0 2 * * *` | Todos los días a las 2:00 AM |
| `0 */4 * * *` | Cada 4 horas |
| `*/30 * * * *` | Cada 30 minutos |
| `0 8-18 * * 1-5` | Lun-Vie cada hora de 8 AM a 6 PM |
| `0 0 * * 0` | Domingos a medianoche |
| `0 0 1 * *` | Primer día de cada mes |

**Validar en:** https://crontab.guru/

### Activar/Desactivar Entidades

```sql
-- ACTIVAR todas las entidades
EXEC sp_UpdateIntegrationSetting 'EnableAsociados', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableProductos', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableMovimientos', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableTasas', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableFechaCorte', 'true';

-- DESACTIVAR temporalmente Movimientos
EXEC sp_UpdateIntegrationSetting 'EnableMovimientos', 'false';

-- Sincronizar SOLO Productos (para pruebas)
EXEC sp_UpdateIntegrationSetting 'EnableAsociados', 'false';
EXEC sp_UpdateIntegrationSetting 'EnableProductos', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableMovimientos', 'false';
EXEC sp_UpdateIntegrationSetting 'EnableTasas', 'false';
EXEC sp_UpdateIntegrationSetting 'EnableFechaCorte', 'false';
```

### Ajustar Tamaño de Lote

```sql
-- Lote de 500 (RECOMENDADO)
EXEC sp_UpdateIntegrationSetting 'BatchSize', '500';

-- Lote de 1000 (para datasets grandes)
EXEC sp_UpdateIntegrationSetting 'BatchSize', '1000';

-- Lote de 100 (para pruebas)
EXEC sp_UpdateIntegrationSetting 'BatchSize', '100';
```

---

## ?? INSTALACIÓN COMO SERVICIO DE WINDOWS

### 1. Publicar la Aplicación

```powershell
cd C:\integradorOptimo

# Publicar para Windows x64
dotnet publish src/Integrador.Worker/Integrador.Worker.csproj `
  -c Release `
  -r win-x64 `
  --self-contained false `
  -o C:\IntegradorOptimo
```

### 2. Instalar como Servicio

```powershell
# Abrir PowerShell como Administrador

# Ir a la carpeta de publicación
cd C:\IntegradorOptimo

# Instalar el servicio
sc.exe create IntegradorOptimo `
  binPath= "C:\IntegradorOptimo\Integrador.Worker.exe" `
  start= auto `
  DisplayName= "Integrador Óptimo - FondoSuma"

# Configurar descripción
sc.exe description IntegradorOptimo "Servicio de sincronización de datos entre ERP y FondoSuma"

# Configurar reinicio automático en caso de fallo
sc.exe failure IntegradorOptimo reset= 86400 actions= restart/60000/restart/60000/restart/60000
```

### 3. Iniciar el Servicio

```powershell
# Iniciar
sc.exe start IntegradorOptimo

# Ver estado
sc.exe query IntegradorOptimo

# Debe mostrar: STATE: RUNNING
```

### 4. Comandos Útiles

```powershell
# Ver estado
sc.exe query IntegradorOptimo

# Detener
sc.exe stop IntegradorOptimo

# Iniciar
sc.exe start IntegradorOptimo

# Reiniciar
sc.exe stop IntegradorOptimo
sc.exe start IntegradorOptimo

# Desinstalar (si es necesario)
sc.exe stop IntegradorOptimo
sc.exe delete IntegradorOptimo
```

---

## ?? MONITOREO

### 1. Ver Logs del Worker

```powershell
# Logs en tiempo real
Get-Content C:\IntegradorOptimo\logs\log-*.txt -Tail 50 -Wait

# Ver logs del día
Get-Content C:\IntegradorOptimo\logs\log-2024-12-20.txt

# Buscar errores
Get-Content C:\IntegradorOptimo\logs\log-*.txt | Select-String "ERROR"
```

### 2. Ver Historial de Ejecuciones

```sql
USE IntegradorDB;

-- Últimas 20 ejecuciones
SELECT TOP 20 * FROM vw_RecentExecutions ORDER BY Id DESC;

-- Ejecuciones exitosas del último mes
SELECT * 
FROM IntegrationExecutionHistory
WHERE Estado = 'Success'
  AND FechaInicio >= DATEADD(MONTH, -1, GETDATE())
ORDER BY FechaInicio DESC;

-- Ejecuciones con errores
SELECT * 
FROM IntegrationExecutionHistory
WHERE Estado = 'Error'
ORDER BY FechaInicio DESC;

-- Estadísticas de performance
SELECT 
    COUNT(*) AS TotalEjecuciones,
    AVG(DuracionSegundos) AS PromedioSegundos,
    MIN(DuracionSegundos) AS MinSegundos,
    MAX(DuracionSegundos) AS MaxSegundos,
    AVG(AsociadosProcesados + ProductosProcesados + MovimientosProcesados) AS PromedioRegistros
FROM IntegrationExecutionHistory
WHERE Estado = 'Success'
  AND FechaInicio >= DATEADD(DAY, -7, GETDATE());
```

### 3. Ver Logs del Servicio de Windows

```powershell
# Event Viewer
eventvwr.msc

# Buscar en: Windows Logs > Application
# Filtrar por: IntegradorOptimo
```

---

## ?? TROUBLESHOOTING

### Problema: El servicio no inicia

**Síntomas:**
- `sc.exe start IntegradorOptimo` falla
- Estado: STOPPED

**Soluciones:**
```powershell
# 1. Ver logs
Get-Content C:\IntegradorOptimo\logs\log-*.txt -Tail 100

# 2. Ejecutar manualmente para ver errores
cd C:\IntegradorOptimo
.\Integrador.Worker.exe

# 3. Verificar permisos de la carpeta
icacls C:\IntegradorOptimo

# 4. Verificar que .NET 8 esté instalado
dotnet --version
```

### Problema: Error de conexión a SQL Server

**Síntomas:**
- `Login failed for user`
- `A network-related error occurred`

**Soluciones:**
```sql
-- 1. Verificar que el usuario existe
SELECT name FROM sys.server_principals WHERE name = 'integrador_user';

-- 2. Verificar permisos
USE CooperativaDB;
EXEC sp_helpuser 'integrador_user';

-- 3. Otorgar permisos si faltan
GRANT SELECT ON genAsociados TO integrador_user;
GRANT SELECT ON genProductos TO integrador_user;
GRANT SELECT ON genMovimiento TO integrador_user;
GRANT SELECT ON admTasas TO integrador_user;
GRANT SELECT ON admEntidades TO integrador_user;
GRANT EXECUTE ON ERP_SPConsultaDta TO integrador_user;
```

```powershell
# 4. Probar conectividad
sqlcmd -S TU_SERVIDOR -U integrador_user -P TU_PASSWORD -Q "SELECT @@VERSION"

# 5. Verificar firewall
Test-NetConnection -ComputerName TU_SERVIDOR -Port 1433
```

### Problema: Error 401 de la API

**Síntomas:**
- `Response status code: 401 (Unauthorized)`

**Soluciones:**
```powershell
# 1. Verificar API Key en appsettings.json
Get-Content C:\IntegradorOptimo\appsettings.json | Select-String "ApiKey"

# 2. Probar la API con curl
curl -X POST https://api.fondosuma.com/api/integration/fecha-corte `
  -H "X-API-Key: TU_API_KEY" `
  -H "Content-Type: application/json" `
  -d '{\"fechaCorte\":\"2024-12-20T00:00:00\"}'

# 3. Verificar conectividad a la API
Test-NetConnection -ComputerName api.fondosuma.com -Port 443
```

### Problema: El Worker no ejecuta a la hora programada

**Síntomas:**
- Logs muestran "Próxima ejecución: ..." pero no ejecuta

**Soluciones:**
```sql
-- 1. Verificar configuración
EXEC sp_ViewCurrentConfiguration;

-- 2. Verificar expresión Cron
SELECT SettingValue FROM IntegrationSettings WHERE SettingKey = 'ScheduleCron';

-- 3. Probar con ejecución frecuente (cada minuto)
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '*/1 * * * *';

-- 4. Ver logs después de 1 minuto
```

```powershell
# 5. Reiniciar el servicio
sc.exe stop IntegradorOptimo
sc.exe start IntegradorOptimo

# 6. Ver logs en tiempo real
Get-Content C:\IntegradorOptimo\logs\log-*.txt -Tail 50 -Wait
```

### Problema: Alto uso de memoria

**Síntomas:**
- El proceso usa mucha RAM
- Performance degradado

**Soluciones:**
```sql
-- 1. Reducir tamaño de lote
EXEC sp_UpdateIntegrationSetting 'BatchSize', '200';

-- 2. Deshabilitar entidades temporalmente
EXEC sp_UpdateIntegrationSetting 'EnableMovimientos', 'false';
```

```powershell
# 3. Monitorear memoria
Get-Process -Name "Integrador.Worker" | Select-Object WorkingSet64, VirtualMemorySize64

# 4. Reiniciar servicio periódicamente (tarea programada)
schtasks /create /tn "Reiniciar Integrador" /tr "sc.exe restart IntegradorOptimo" /sc daily /st 01:00
```

---

## ? CHECKLIST DE INSTALACIÓN

### Pre-Instalación
- [ ] .NET 8 Runtime instalado
- [ ] SQL Server accesible
- [ ] Permisos de administrador
- [ ] API Key obtenida

### Base de Datos
- [ ] IntegradorDB creada
- [ ] Script `01_CreateDatabase.sql` ejecutado
- [ ] Configuración inicial verificada con `sp_ViewCurrentConfiguration`
- [ ] SP del ERP `ERP_SPConsultaDta` verificado

### Aplicación
- [ ] Código descargado
- [ ] `appsettings.json` configurado
- [ ] Conexiones probadas
- [ ] Compilación exitosa

### Servicio
- [ ] Aplicación publicada en `C:\IntegradorOptimo`
- [ ] Servicio instalado
- [ ] Servicio iniciado
- [ ] Logs verificados

### Configuración
- [ ] Horario configurado
- [ ] Entidades activas configuradas
- [ ] Tamaño de lote ajustado
- [ ] Primera ejecución exitosa

---

## ?? SOPORTE

**Documentación:**
- README.md
- FULL_DATA_MIGRATION.md
- DATA_TYPES_MAPPING.md
- API_PROMPT.md

**Scripts:**
- `scripts/01_CreateDatabase.sql`
- `scripts/02_ConfigurationScripts.sql`

**Logs:**
- `C:\IntegradorOptimo\logs\log-YYYY-MM-DD.txt`

---

?? **¡Instalación Completada!**

El Worker Service está listo para sincronizar datos automáticamente según el horario configurado.
