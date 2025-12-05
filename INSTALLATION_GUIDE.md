# ?? GUÍA COMPLETA DE INSTALACIÓN - IntegradorOptimo v1.1

## ¡Bienvenido al IntegradorOptimo!

Este documento es la **guía definitiva y actualizada** para instalar y configurar el IntegradorOptimo, incluyendo todos los ajustes necesarios para tu entorno específico.

**Versión**: 1.1.1  
**Fecha**: Enero 2025  
**Estado**: Ajustado para SP real del cliente  

---

## ?? TABLA DE CONTENIDOS

1. [Pre-requisitos](#pre-requisitos)
2. [Arquitectura del Sistema](#arquitectura-del-sistema)
3. [Instalación Paso a Paso](#instalación-paso-a-paso)
4. [Configuración del Stored Procedure](#configuración-del-stored-procedure)
5. [Configuración de la Aplicación](#configuración-de-la-aplicación)
6. [Pruebas Locales](#pruebas-locales)
7. [Instalación como Servicio](#instalación-como-servicio)
8. [Configuración Inicial](#configuración-inicial)
9. [Monitoreo y Verificación](#monitoreo-y-verificación)
10. [Resolución de Problemas](#resolución-de-problemas)

---

## ? PRE-REQUISITOS

### **Software Requerido:**

- [ ] **Windows Server** (2016, 2019, 2022) o Windows 10/11 Pro
- [ ] **.NET 8 Runtime** ([descargar aquí](https://dotnet.microsoft.com/download/dotnet/8.0))
- [ ] **SQL Server** accesible (2016+)
- [ ] **SQL Server Management Studio** (SSMS)
- [ ] **PowerShell 5.1** o superior

### **Permisos Necesarios:**

- [ ] **Administrador local** en el servidor Windows
- [ ] **Permisos SQL** en base de datos ERP:
  - `SELECT` en tablas: `genAsociados`, `genProductos`, `genMovimiento`, `admTasas`, `admEntidades`
  - `EXECUTE` en SP: `ERP_SPConsultaDta`
- [ ] **Permisos SQL** en base de datos de configuración:
  - `CREATE TABLE`, `INSERT`, `UPDATE`, `SELECT` en esquema `dbo`

### **Información Requerida:**

- [ ] **Servidor SQL ERP**: Nombre/IP y puerto
- [ ] **Base de datos ERP**: Nombre de la BD
- [ ] **Credenciales SQL ERP**: Usuario y contraseña
- [ ] **Servidor SQL Configuración**: Nombre/IP y puerto (puede ser el mismo)
- [ ] **Base de datos Configuración**: Nombre de la BD
- [ ] **Token JWT** de la API FondoSuma
- [ ] **URL de la API**: Normalmente `https://api.fodnosuma.com`

### **Verificación de .NET 8:**

```powershell
dotnet --version
# Debe mostrar: 8.0.x o superior
```

Si no está instalado:
```powershell
# Descargar e instalar .NET 8 Runtime
# https://dotnet.microsoft.com/download/dotnet/8.0/runtime
```

---

## ??? ARQUITECTURA DEL SISTEMA

### **Componentes Principales:**

```
???????????????????????????????????????????????????????????????
?                    INTEGRADOR ÓPTIMO                        ?
?                  Windows Service (.NET 8)                   ?
???????????????????????????????????????????????????????????????
                              ?
                              ???????????????????????????????????
                              ?                                 ?
???????????????????????????????????????     ????????????????????????????????
?     BASE DE DATOS ERP               ?     ?  BASE DE DATOS CONFIGURACIÓN ?
?  (Origen de datos)                  ?     ?  (Tabla IntegrationSettings) ?
?                                     ?     ?                              ?
?  • genAsociados                     ?     ?  • ScheduleCron              ?
?  • genProductos                     ?     ?  • BatchSize                 ?
?  • genMovimiento                    ?     ?  • Enable[Entidades]         ?
?  • admTasas                         ?     ?  • DailyTruncateHour         ?
?  • admEntidades                     ?     ????????????????????????????????
?                                     ?
?  SP: ERP_SPConsultaDta              ?
???????????????????????????????????????
                              ?
                              ?
???????????????????????????????????????????????????????????????
?                      API FONDOSUMA                          ?
?              https://api.fodnosuma.com                      ?
?                                                             ?
?  POST /api/integration/asociados                           ?
?  POST /api/integration/productos?isFullLoad=true/false     ?
?  POST /api/integration/movimientos                         ?
?  POST /api/integration/tasas                               ?
?  POST /api/integration/fecha-corte                         ?
???????????????????????????????????????????????????????????????
```

### **Capas de la Aplicación:**

1. **Integrador.Core** - DTOs y Models
   - `AsociadoDto`, `ProductoDto`, `MovimientoDto`, `TasaDto`, `FechaCorteDto`
   - `IntegrationSettings`

2. **Integrador.Infrastructure** - Acceso a datos
   - `ErpRepository` - Lee datos del ERP vía SP
   - `IntegrationSettingsRepository` - Lee configuración

3. **Integrador.Worker** - Lógica de negocio
   - `IntegrationWorker` - BackgroundService principal
   - `ApiClientService` - Cliente HTTP con Polly
   - `PollyPolicies` - Reintentos y Circuit Breaker

### **Flujo de Sincronización:**

```
1. Worker lee configuración de IntegrationSettings
2. Calcula próxima ejecución según ScheduleCron
3. Espera hasta la hora programada
4. Para cada entidad habilitada:
   a. Lee datos del ERP con ErpRepository
   b. Divide en lotes de BatchSize (ej: 500)
   c. Envía cada lote a la API con ApiClientService
   d. Registra logs detallados con Serilog
5. Vuelve al paso 1
```

---

## ?? INSTALACIÓN PASO A PASO

### **PASO 1: Obtener el Código**

#### **Opción A: Clonar desde Git** (Recomendado)

```powershell
# Navegar a tu carpeta de proyectos
cd C:\Projects

# Clonar el repositorio
git clone https://github.com/Estebanmg58/integradorOptimo.git

# Entrar a la carpeta
cd integradorOptimo

# Verificar que tienes todos los archivos
ls
```

#### **Opción B: Copiar archivos manualmente**

1. Descarga el ZIP del repositorio
2. Extrae en `C:\Projects\integradorOptimo`
3. Verifica que tienes la estructura completa:
   ```
   integradorOptimo/
   ??? src/
   ??? scripts/
   ??? Install-Service.ps1
   ??? README.md
   ??? FIRST_USE.md
   ```

---

### **PASO 2: Configurar Base de Datos de Configuración**

#### **2.1. Conectarse a SQL Server Management Studio (SSMS)**

1. Abre SSMS
2. Conecta al servidor donde estará la base de datos de configuración
3. Puede ser el mismo servidor del ERP o uno diferente

#### **2.2. Crear o Seleccionar Base de Datos**

```sql
-- Opción 1: Usar base de datos existente
USE IntegradorDB;
GO

-- Opción 2: Crear nueva base de datos
CREATE DATABASE IntegradorDB;
GO
USE IntegradorDB;
GO
```

#### **2.3. Ejecutar Script de Configuración**

1. En SSMS, abre el archivo: `scripts/CreateIntegrationSettings.sql`
2. Verifica que estás en la base de datos correcta
3. Ejecuta el script completo (F5)

Deberías ver:

```
? Tabla IntegrationSettings creada exitosamente
? Configuración inicial insertada exitosamente
? Script completado exitosamente
```

#### **2.4. Verificar la Tabla Creada**

```sql
SELECT * FROM IntegrationSettings;
```

**Resultado esperado**: 8 registros

| SettingKey | SettingValue |
|------------|-------------|
| ScheduleCron | 0 2 * * * |
| BatchSize | 500 |
| DailyTruncateHour | 2 |
| EnableAsociados | true |
| EnableProductos | true |
| EnableMovimientos | true |
| EnableTasas | true |
| EnableFechaCorte | true |

---

### **PASO 3: Configurar Stored Procedure del ERP**

#### **3.1. Verificar que Existe el SP**

```sql
USE TuBaseDatosERP;  -- Reemplaza con el nombre real
GO

SELECT * FROM sys.procedures WHERE name = 'ERP_SPConsultaDta';
```

**Si retorna 1 fila**: ? El SP existe  
**Si retorna 0 filas**: ? Necesitas crear el SP

#### **3.2. Analizar tu SP Actual**

Tu SP `ERP_SPConsultaDta` debe tener estos tipos de consulta:

| @TipoConsulta | Retorna | Tabla Origen |
|---------------|---------|--------------|
| 1 | Asociados | `genAsociados` |
| 2 | Productos | `genProductos` |
| 3 | Fecha Corte | `admEntidades` |
| 4 | Tasas | `admTasas` |
| 5 | Productos (lookup) | `genProductos` |
| 6 | **Movimientos** | `genMovimiento` |

#### **3.3. ?? IMPORTANTE: Ajuste para Movimientos**

**Tu SP actual requiere parámetros para @TipoConsulta = 6:**
- `@CodigoProducto` (INT)
- `@Consecutivo` (VARCHAR)

**Esto impide obtener TODOS los movimientos para sincronización.**

**Solución Recomendada**: Modifica el SP para soportar parámetros NULL

```sql
-- Modifica tu SP ERP_SPConsultaDta
-- Encuentra la sección @TipoConsulta = 6 y reemplázala con:

IF(@TipoConsulta = 6)
BEGIN
    IF @CodigoProducto IS NULL AND @Consecutivo IS NULL
    BEGIN
        -- Sincronización: Retornar movimientos recientes (últimos 3 meses)
        SELECT [id]
              ,[CodigoEntidad]
              ,[CodigoOficina]
              ,[CodigoProducto]
              ,[Consecutivo]
              ,[Fecha]
              ,[Operacion]
              ,[Naturaleza]
              ,[Valor]
              ,[Cuota]
        FROM [genMovimiento]
        WHERE [Fecha] >= DATEADD(MONTH, -3, GETDATE())
        ORDER BY [Fecha] DESC
    END
    ELSE
    BEGIN
        -- Consulta original con filtros específicos
        SELECT [id]
              ,[CodigoEntidad]
              ,[CodigoOficina]
              ,[CodigoProducto]
              ,[Consecutivo]
              ,[Fecha]
              ,[Operacion]
              ,[Naturaleza]
              ,[Valor]
              ,[Cuota]
        FROM [genMovimiento]
        WHERE [CodigoProducto] = @CodigoProducto
        AND   Consecutivo LIKE '%'+@Consecutivo+'%'
    END
END
```

**Aplica la modificación**:
```sql
ALTER PROCEDURE [dbo].[ERP_SPConsultaDta]
    @TipoConsulta INT,
    @CodigoProducto INT = NULL,
    @Consecutivo VARCHAR(15) = NULL
AS
BEGIN
    -- ... (código existente para @TipoConsulta 1-5) ...
    
    -- Reemplaza tu IF(@TipoConsulta = 6) con el código de arriba
END
GO
```

#### **3.4. Probar el SP Modificado**

```sql
-- Probar cada tipo de consulta:

-- 1. Asociados
EXEC ERP_SPConsultaDta @TipoConsulta = 1, @CodigoProducto = NULL, @Consecutivo = NULL;
-- Debe retornar datos de genAsociados

-- 2. Productos
EXEC ERP_SPConsultaDta @TipoConsulta = 2, @CodigoProducto = NULL, @Consecutivo = NULL;
-- Debe retornar productos activos (sin FechaRetiro)

-- 3. Fecha Corte
EXEC ERP_SPConsultaDta @TipoConsulta = 3, @CodigoProducto = NULL, @Consecutivo = NULL;
-- Debe retornar FechaCorte de admEntidades (id=1)

-- 4. Tasas
EXEC ERP_SPConsultaDta @TipoConsulta = 4, @CodigoProducto = NULL, @Consecutivo = NULL;
-- Debe retornar tasas de admTasas

-- 6. Movimientos (SIN FILTROS - NUEVO)
EXEC ERP_SPConsultaDta @TipoConsulta = 6, @CodigoProducto = NULL, @Consecutivo = NULL;
-- Debe retornar movimientos de los últimos 3 meses

-- 6. Movimientos (CON FILTROS - ORIGINAL)
EXEC ERP_SPConsultaDta @TipoConsulta = 6, @CodigoProducto = 1, @Consecutivo = '12345';
-- Debe retornar movimientos filtrados
```

? **Todos deben retornar datos correctamente**

#### **3.5. Verificar Volúmenes**

```sql
-- Contar registros por entidad
SELECT 'Asociados' AS Entidad, COUNT(*) AS Total FROM genAsociados
UNION ALL
SELECT 'Productos', COUNT(*) FROM genProductos WHERE FechaRetiro IS NULL
UNION ALL
SELECT 'Movimientos (3 meses)', COUNT(*) FROM genMovimiento WHERE Fecha >= DATEADD(MONTH, -3, GETDATE())
UNION ALL
SELECT 'Tasas', COUNT(*) FROM admTasas;
```

Anota estos números para referencia.

---

### **PASO 4: Configurar Credenciales de la Aplicación**

#### **4.1. Abrir el archivo de configuración**

```powershell
notepad src\Integrador.Worker\appsettings.json
```

#### **4.2. Configurar ConnectionStrings**

Reemplaza los placeholders con tus valores reales:

```json
{
  "ConnectionStrings": {
    "ErpDatabase": "Server=TU_SERVIDOR_ERP;Database=TU_BD_ERP;User Id=TU_USUARIO_ERP;Password=TU_PASSWORD_ERP;TrustServerCertificate=true;",
    "DestinationDatabase": "Server=TU_SERVIDOR_CONFIG;Database=IntegradorDB;User Id=TU_USUARIO_CONFIG;Password=TU_PASSWORD_CONFIG;TrustServerCertificate=true;"
  },
  "ApiSettings": {
    "BaseUrl": "https://api.fodnosuma.com",
    "JwtToken": "TU_TOKEN_JWT_REAL_AQUI"
  },
  "Serilog": {
    "MinimumLevel": {
      "Default": "Information"
    }
  }
}
```

#### **Ejemplo con valores reales**:

```json
{
  "ConnectionStrings": {
    "ErpDatabase": "Server=192.168.1.10;Database=CoopDB;User Id=integrador_user;Password=P@ssw0rd123!;TrustServerCertificate=true;",
    "DestinationDatabase": "Server=192.168.1.10;Database=IntegradorDB;User Id=integrador_user;Password=P@ssw0rd123!;TrustServerCertificate=true;"
  },
  "ApiSettings": {
    "BaseUrl": "https://api.fodnosuma.com",
    "JwtToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

#### **4.3. Notas Importantes**:

- ? Usa `TrustServerCertificate=true` si SQL Server usa certificado autofirmado
- ? Puedes usar **Windows Authentication** cambiando a: `Integrated Security=true;` (y quitando User Id/Password)
- ? El Token JWT lo obtienes del equipo de la API FondoSuma
- ? **NO compartas** este archivo con el token real en Git

#### **4.4. Guardar y cerrar**

Presiona `Ctrl+S` para guardar.

---

### **PASO 5: Compilar y Probar Localmente**

#### **5.1. Navegar a la carpeta del Worker**

```powershell
cd src\Integrador.Worker
```

#### **5.2. Restaurar paquetes NuGet**

```powershell
dotnet restore
```

Deberías ver:
```
Determining projects to restore...
Restored ... (in X.XX sec)
```

#### **5.3. Compilar en modo Debug**

```powershell
dotnet build
```

**Resultado esperado**:
```
Build succeeded.
    0 Warning(s)
    0 Error(s)
```

Si hay errores, revisa:
- ? .NET 8 SDK instalado
- ? Referencias de proyectos correctas
- ? Paquetes NuGet restaurados

#### **5.4. Ejecutar en modo desarrollo**

```powershell
dotnet run
```

**Salida esperada**:

```
[12:30:15 INF] ?? Integrador Óptimo iniciado - Servicio de Windows activo
[12:30:15 INF] ? Próxima ejecución programada: 2025-01-06 02:00:00
```

? **El servicio está funcionando y esperando la próxima ejecución**

#### **5.5. Prueba Inmediata (Opcional)**

Para no esperar hasta las 2 AM, cambia temporalmente el cron:

```sql
-- En SSMS, en la base de datos de configuración:
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '*/2 * * * *';
-- Ejecutará cada 2 minutos
```

```powershell
# Detener la aplicación (Ctrl+C)
# Volver a ejecutar
dotnet run

# En 2 minutos verás:
[12:32:00 INF] ========================================
[12:32:00 INF] ?? INICIANDO SINCRONIZACIÓN COMPLETA
[12:32:00 INF] ========================================
[12:32:01 INF] ?? Sincronizando Asociados...
[12:32:02 INF]    Total asociados obtenidos: 8,543
[12:32:02 INF]    ? Batch 1/18: 500 registros en 345ms
...
```

#### **5.6. Verificar Logs Generados**

```powershell
# Ver logs generados
Get-Content logs\log-*.txt -Tail 50
```

#### **5.7. Restablecer Cron para Producción**

Cuando termines las pruebas:

```sql
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 2 * * *';
-- Volver a ejecución diaria a las 2 AM
```

---

### **PASO 6: Instalar como Servicio de Windows**

#### **6.1. Preparar el Entorno**

1. **Detener** la aplicación si está corriendo (`Ctrl+C`)
2. Volver a la raíz del proyecto:
   ```powershell
   cd ..\..
   # Deberías estar en: C:\Projects\integradorOptimo
   ```

#### **6.2. Abrir PowerShell como Administrador**

1. Cierra la ventana actual de PowerShell
2. Busca "PowerShell" en el menú Inicio
3. Haz clic derecho ? **"Ejecutar como administrador"**
4. Navega al proyecto:
   ```powershell
   cd C:\Projects\integradorOptimo
   ```

#### **6.3. Ejecutar el Script de Instalación**

```powershell
.\Install-Service.ps1 -Action install
```

**Proceso de instalación**:

```
=========================================
?? INSTALACIÓN DE INTEGRADOR ÓPTIMO
=========================================
?? Compilando proyecto en modo Release...
  ? Build exitoso

?? Publicando aplicación en C:\IntegradorOptimo...
  ? Archivos publicados

?? Creando directorio de logs: C:\Logs\IntegradorOptimo
  ? Directorio creado

??  Registrando servicio de Windows...
  ? Servicio creado: IntegradorOptimo

?? Configurando reinicio automático en caso de fallo...
  ? Política de reinicio configurada

??  Iniciando servicio...
  ? Servicio iniciado

=========================================
? INSTALACIÓN COMPLETADA EXITOSAMENTE
=========================================

?? Estado del servicio:
   Nombre: IntegradorOptimo
   Estado: Running
   Inicio: Automático
   Ruta: C:\IntegradorOptimo\Integrador.Worker.exe

?? Logs disponibles en: C:\Logs\IntegradorOptimo

?? Comandos útiles:
   Ver estado:   sc.exe query IntegradorOptimo
   Detener:      Stop-Service -Name IntegradorOptimo
   Iniciar:      Start-Service -Name IntegradorOptimo
   Ver logs:     Get-Content C:\Logs\IntegradorOptimo\log-*.txt -Tail 50 -Wait
```

#### **6.4. Verificar Instalación**

```powershell
# Ver estado del servicio
.\Install-Service.ps1 -Action status
```

Debe mostrar:
```
Nombre:        IntegradorOptimo
Estado:        Running
Tipo Inicio:   Automatic
```

---

### **PASO 7: Verificación Post-Instalación**

#### **7.1. Ver Logs en Tiempo Real**

```powershell
.\Install-Service.ps1 -Action logs
```

Presiona `Ctrl+C` para salir.

#### **7.2. Ver en Servicios de Windows**

```powershell
# Abrir administrador de servicios
services.msc
```

Busca: **IntegradorOptimo**

Debe mostrar:
- **Estado**: Iniciado
- **Tipo de inicio**: Automático

#### **7.3. Verificar Primera Sincronización**

```powershell
# Al día siguiente (o según tu cron configurado), busca logs de sincronización
Get-Content C:\Logs\IntegradorOptimo\log-*.txt | Select-String "SINCRONIZACIÓN COMPLETADA"
```

Deberías ver algo como:
```
2025-01-06 02:00:45 [INF] ? SINCRONIZACIÓN COMPLETADA EN 42.3s
```

---

## ?? CONFIGURACIÓN INICIAL

### **Para Ambiente de Pruebas**

```sql
-- Ejecutar cada 10 minutos para pruebas rápidas
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '*/10 * * * *';

-- Lotes pequeños para ver más batches en logs
EXEC sp_UpdateIntegrationSetting 'BatchSize', '100';

-- Solo habilitar Asociados inicialmente (para probar)
EXEC sp_UpdateIntegrationSetting 'EnableAsociados', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableProductos', 'false';
EXEC sp_UpdateIntegrationSetting 'EnableMovimientos', 'false';
EXEC sp_UpdateIntegrationSetting 'EnableTasas', 'false';
EXEC sp_UpdateIntegrationSetting 'EnableFechaCorte', 'false';

-- Ver configuración actual
SELECT * FROM IntegrationSettings;
```

### **Para Producción**

```sql
-- Ejecutar diariamente a las 2:00 AM
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 2 * * *';

-- Lotes de 500-1000 (según volumen de datos)
EXEC sp_UpdateIntegrationSetting 'BatchSize', '500';

-- Para volúmenes grandes (>100K registros):
-- EXEC sp_UpdateIntegrationSetting 'BatchSize', '1000';

-- Habilitar todas las entidades
EXEC sp_UpdateIntegrationSetting 'EnableAsociados', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableProductos', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableMovimientos', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableTasas', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableFechaCorte', 'true';

-- Productos FullLoad a las 2 AM (misma hora que sincronización)
EXEC sp_UpdateIntegrationSetting 'DailyTruncateHour', '2';

-- Verificar configuración
SELECT * FROM IntegrationSettings ORDER BY SettingKey;
```

### **Ejemplos de Cron Expressions**

| Expresión | Descripción |
|-----------|-------------|
| `0 2 * * *` | Todos los días a las 2:00 AM |
| `0 */4 * * *` | Cada 4 horas |
| `*/30 * * * *` | Cada 30 minutos |
| `0 0 * * 1` | Todos los lunes a medianoche |
| `0 8-18 * * 1-5` | Lunes a viernes, cada hora de 8 AM a 6 PM |
| `0 0 1 * *` | Primer día de cada mes a medianoche |

Usa [crontab.guru](https://crontab.guru/) para validar tu expresión.

---

## ?? MONITOREO Y VERIFICACIÓN

### **Día 1: Verificar Primera Ejecución**

```powershell
# Al día siguiente de instalar, buscar sincronización completada
Get-Content C:\Logs\IntegradorOptimo\log-*.txt | Select-String "SINCRONIZACIÓN COMPLETADA"
```

**Resultado esperado**:
```
2025-01-06 02:00:45.123 [INF] ? SINCRONIZACIÓN COMPLETADA EN 42.3s
```

### **Semana 1: Revisar Patrones**

```powershell
# Ver todas las sincronizaciones de la semana
Get-Content C:\Logs\IntegradorOptimo\log-*.txt | 
    Select-String "SINCRONIZACIÓN COMPLETADA" | 
    Select-Object -Last 7
```

```powershell
# Buscar errores
Get-Content C:\Logs\IntegradorOptimo\log-*.txt | 
    Select-String "ERROR|Exception"
    
# Si no hay resultados: ? Todo bien
```

```sql
-- Verificar con el equipo de la API que los datos llegaron correctamente
-- Comparar conteos:

-- En tu BD ERP:
SELECT COUNT(*) AS TotalAsociados FROM genAsociados;
SELECT COUNT(*) AS TotalProductos FROM genProductos WHERE FechaRetiro IS NULL;

-- Solicitar al equipo de la API los conteos en su lado
```

### **Mensual: Revisión de Logs**

```powershell
# Ver tamaño de logs
Get-ChildItem C:\Logs\IntegradorOptimo\log-*.txt | 
    Measure-Object -Property Length -Sum | 
    Select-Object @{Name="Total (MB)";Expression={[math]::Round($_.Sum/1MB,2)}}

# Verificar rotación (máximo 30 archivos)
Get-ChildItem C:\Logs\IntegradorOptimo\log-*.txt | 
    Measure-Object | 
    Select-Object Count

# Listar logs con fechas
Get-ChildItem C:\Logs\IntegradorOptimo\log-*.txt | 
    Sort-Object LastWriteTime -Descending | 
    Select-Object Name, LastWriteTime, @{Name="Size (KB)";Expression={[math]::Round($_.Length/1KB,2)}} |
    Format-Table -AutoSize
```

### **Monitoreo de Memoria (Para Grandes Volúmenes)**

```powershell
# Ver uso actual de memoria
Get-Process -Name "Integrador.Worker" -ErrorAction SilentlyContinue | 
    Select-Object Name, 
                  @{Name="WorkingSet (MB)";Expression={[math]::Round($_.WorkingSet/1MB,2)}},
                  @{Name="PrivateMemory (MB)";Expression={[math]::Round($_.PrivateMemorySize64/1MB,2)}}

# Monitoreo continuo cada 10 segundos
while($true) {
    Clear-Host
    Write-Host "=== MONITOREO INTEGRADOR ÓPTIMO ===" -ForegroundColor Cyan
    Write-Host ""
    Get-Process -Name "Integrador.Worker" -ErrorAction SilentlyContinue | 
        Select-Object @{Name="Memoria (MB)";Expression={[math]::Round($_.WorkingSet/1MB,2)}},
                      @{Name="CPU (%)";Expression={$_.CPU}} | 
        Format-Table -AutoSize
    Start-Sleep -Seconds 10
}
# Presiona Ctrl+C para detener
```

---

## ?? RESOLUCIÓN DE PROBLEMAS

### **Problema 1: El servicio no inicia**

**Síntomas**:
- Estado del servicio: "Stopped"
- No se generan logs

**Diagnóstico**:
```powershell
# Ver estado detallado
.\Install-Service.ps1 -Action status

# Ver últimos logs
Get-Content C:\Logs\IntegradorOptimo\log-*.txt -Tail 100

# Ver Event Viewer
Get-EventLog -LogName Application -Source "IntegradorOptimo" -Newest 10 -ErrorAction SilentlyContinue
```

**Soluciones**:

1. **Verificar configuración**:
   ```powershell
   notepad C:\IntegradorOptimo\appsettings.json
   # Verificar JSON válido, sin errores de sintaxis
   ```

2. **Verificar permisos**:
   ```powershell
   # Dar permisos al directorio de logs
   icacls "C:\Logs\IntegradorOptimo" /grant "NT AUTHORITY\NETWORK SERVICE:(OI)(CI)F"
   ```

3. **Reinstalar**:
   ```powershell
   .\Install-Service.ps1 -Action uninstall
   .\Install-Service.ps1 -Action install
   ```

---

### **Problema 2: Error de conexión a SQL Server**

**Síntomas**:
```
[ERR] Cannot open database
[ERR] Login failed for user
```

**Diagnóstico**:
```powershell
# Probar conectividad
Test-NetConnection -ComputerName TU_SERVIDOR_SQL -Port 1433
```

**Soluciones**:

1. **Verificar servidor accesible**:
   - Firewall permite puerto 1433
   - SQL Server acepta conexiones remotas
   - Named Pipes / TCP/IP habilitados en SQL Server Configuration Manager

2. **Verificar credenciales**:
   ```powershell
   # Probar conexión con sqlcmd
   sqlcmd -S TU_SERVIDOR -U TU_USUARIO -P TU_PASSWORD -Q "SELECT @@VERSION"
   ```

3. **Verificar permisos del usuario SQL**:
   ```sql
   USE ErpDatabase;
   GO
   GRANT SELECT ON SCHEMA::dbo TO tu_usuario;
   GRANT EXECUTE ON dbo.ERP_SPConsultaDta TO tu_usuario;
   ```

4. **TrustServerCertificate**:
   Asegúrate que está en `true` en `appsettings.json` si usas certificado autofirmado

---

### **Problema 3: SP retorna error o datos vacíos**

**Síntomas**:
```
[ERR] Could not find stored procedure 'ERP_SPConsultaDta'
[WRN] Total asociados obtenidos: 0
```

**Diagnóstico**:
```sql
-- Verificar que existe
USE TuBaseDatosERP;
GO
SELECT * FROM sys.procedures WHERE name = 'ERP_SPConsultaDta';

-- Probar manualmente
EXEC ERP_SPConsultaDta @TipoConsulta = 1, @CodigoProducto = NULL, @Consecutivo = NULL;
```

**Soluciones**:

1. **SP no existe**: Crearlo o verificar el nombre
2. **SP existe pero con otro nombre**: Actualizar `ErpRepository.cs`
3. **SP retorna 0 filas**: Verificar filtros en el SP (ej: `FechaRetiro IS NULL`)

---

### **Problema 4: Error HTTP 401 de la API**

**Síntomas**:
```
[ERR] Response status code does not indicate success: 401 (Unauthorized)
```

**Soluciones**:

1. **Token JWT expirado**:
   - Solicitar nuevo token al equipo de la API
   - Actualizar en `appsettings.json`
   - Reiniciar servicio:
     ```powershell
     .\Install-Service.ps1 -Action restart
     ```

2. **Token inválido**:
   - Verificar que el token es correcto (sin espacios extras)
   - Verificar formato: `"Bearer {token}"` solo si la API lo requiere

---

### **Problema 5: Sincronización muy lenta**

**Síntomas**:
```
[INF] ? SINCRONIZACIÓN COMPLETADA EN 300.5s
```

(Más de 5 minutos)

**Optimizaciones**:

1. **Aumentar BatchSize**:
   ```sql
   EXEC sp_UpdateIntegrationSetting 'BatchSize', '1000';
   ```

2. **Agregar índices en tablas del ERP**:
   ```sql
   -- Índice en genMovimiento para consultas por fecha
   CREATE NONCLUSTERED INDEX IX_genMovimiento_Fecha
   ON genMovimiento (Fecha DESC)
   INCLUDE (CodigoProducto, Consecutivo, Operacion, Valor);
   
   -- Índice en genProductos
   CREATE NONCLUSTERED INDEX IX_genProductos_FechaRetiro
   ON genProductos (FechaRetiro)
   INCLUDE (CodigoProducto, Consecutivo, Saldo);
   ```

3. **Reducir rango de movimientos**:
   Modifica el SP para usar 1 mes en lugar de 3:
   ```sql
   WHERE [Fecha] >= DATEADD(MONTH, -1, GETDATE())
   ```

---

### **Problema 6: Datasets grandes (>200K registros)**

**Síntomas**:
```
[WRN] ??  Dataset grande detectado (215,340 registros). Activando optimizaciones de memoria.
```

**Esto es NORMAL**, el sistema está diseñado para manejarlos.

**Monitoreo recomendado**:
```powershell
# Ver logs de limpieza de memoria
Get-Content C:\Logs\IntegradorOptimo\log-*.txt | 
    Select-String "?? Memoria liberada|Dataset grande detectado"
```

**Optimizaciones adicionales** (si es necesario):
```sql
-- Aumentar BatchSize
EXEC sp_UpdateIntegrationSetting 'BatchSize', '1500';

-- O limitar rango de datos en el SP
```

---

## ? CHECKLIST FINAL DE INSTALACIÓN

Antes de dar por terminada la instalación, verifica:

### **Base de Datos**
- [ ] Tabla `IntegrationSettings` creada en BD de configuración
- [ ] 8 registros de configuración insertados
- [ ] SP `sp_UpdateIntegrationSetting` creado y funcional
- [ ] SP `ERP_SPConsultaDta` existe en BD del ERP
- [ ] SP modificado para soportar movimientos sin filtros (@TipoConsulta = 6 con NULL params)
- [ ] Todos los tipos de consulta probados y retornan datos

### **Aplicación**
- [ ] Código clonado/copiado en `C:\Projects\integradorOptimo`
- [ ] `appsettings.json` configurado con credenciales reales
- [ ] Token JWT válido configurado
- [ ] Compilación exitosa (`dotnet build`)
- [ ] Prueba local exitosa (`dotnet run`)

### **Servicio de Windows**
- [ ] Servicio instalado como `IntegradorOptimo`
- [ ] Estado del servicio: **Running**
- [ ] Tipo de inicio: **Automático**
- [ ] Reinicio automático configurado
- [ ] Logs generándose en `C:\Logs\IntegradorOptimo\`

### **Configuración**
- [ ] Cron configurado según necesidad (ej: `0 2 * * *`)
- [ ] BatchSize apropiado para tu volumen (500-1000)
- [ ] Entidades habilitadas según necesidad
- [ ] `DailyTruncateHour` configurado

### **Verificación**
- [ ] Primera sincronización ejecutada exitosamente
- [ ] Logs sin errores
- [ ] Datos llegaron a la API (verificado con equipo de API)
- [ ] Memoria del proceso estable (<500 MB)

---

## ?? DOCUMENTACIÓN ADICIONAL

### **Documentos de Referencia**:

| Documento | Descripción | Cuándo Leerlo |
|-----------|-------------|---------------|
| **README.md** | Documentación técnica completa | Para entender el sistema |
| **QUICKSTART.md** | Configuración rápida (5 pasos) | Si ya instalaste antes |
| **TROUBLESHOOTING.md** | Solución de problemas detallada | Cuando tengas problemas |
| **PROJECT_STRUCTURE.md** | Arquitectura y estructura del código | Para desarrolladores |
| **IMPORTANT_SP_ADJUSTMENTS.md** | Ajustes específicos para tu SP | CRÍTICO - Ajustes del SP |
| **PERFORMANCE_IMPROVEMENTS.md** | Optimizaciones v1.1 para grandes volúmenes | Para datasets >100K |

### **Scripts SQL Útiles**:

| Script | Descripción |
|--------|-------------|
| `CreateIntegrationSettings.sql` | Crear tabla de configuración |
| `SP_Documentation.sql` | Documentación de tu SP real |
| `ERP_SPConsultaDta_Example.sql` | Ejemplo genérico de SP |

---

## ?? ¡INSTALACIÓN COMPLETADA!

Si llegaste hasta aquí y completaste todos los pasos, **¡Felicidades!**

Tu **IntegradorOptimo** ahora:

? Se ejecuta automáticamente según el cron configurado  
? Sincroniza datos del ERP a la API FondoSuma  
? Procesa grandes volúmenes eficientemente (hasta 200K+ registros)  
? Genera logs detallados de cada sincronización  
? Se reinicia automáticamente si falla  
? Lee configuración dinámica sin necesidad de reiniciar  

---

## ?? SOPORTE

### **¿Tienes dudas?**

1. **Revisa la documentación**:
   - `README.md` para información general
   - `TROUBLESHOOTING.md` para problemas específicos
   - `IMPORTANT_SP_ADJUSTMENTS.md` para dudas del SP

2. **Busca en logs**:
   ```powershell
   Get-Content C:\Logs\IntegradorOptimo\log-*.txt | Select-String "ERROR"
   ```

3. **Ejecuta el checklist** de verificación de arriba

### **Comandos Útiles de Referencia**:

```powershell
# Ver estado
.\Install-Service.ps1 -Action status

# Ver logs en tiempo real
.\Install-Service.ps1 -Action logs

# Reiniciar servicio
.\Install-Service.ps1 -Action restart

# Desinstalar servicio
.\Install-Service.ps1 -Action uninstall

# Ver memoria del proceso
Get-Process -Name "Integrador.Worker" | Select-Object WorkingSet64
```

```sql
-- Ver configuración
SELECT * FROM IntegrationSettings ORDER BY SettingKey;

-- Cambiar horario
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 3 * * *';

-- Cambiar tamaño de lote
EXEC sp_UpdateIntegrationSetting 'BatchSize', '1000';

-- Deshabilitar entidad
EXEC sp_UpdateIntegrationSetting 'EnableMovimientos', 'false';
```

---

**Versión del Documento**: 1.1.1  
**Última Actualización**: Enero 2025  
**Autor**: IntegradorOptimo Team  
**Estado**: ? Validado con SP real del cliente  

?? **¡TODO MELO CARAMELO!** ??

---

## ?? HISTORIAL DE CAMBIOS

### v1.1.1 (Enero 2025)
- ? Ajustado para SP real del cliente con 6 tipos de consulta
- ? Agregado soporte para @TipoConsulta = 6 (Movimientos) con parámetros NULL
- ? Mapeo de columnas actualizado según tablas reales del ERP
- ? Optimizaciones de memoria para datasets >100K
- ? Documentación completa del proceso de instalación
- ? Checklist exhaustivo de verificación

### v1.0.0 (Diciembre 2024)
- ? Versión inicial del IntegradorOptimo
- ? Arquitectura de 3 capas implementada
- ? Windows Service funcional
- ? Polly policies para resiliencia
- ? Serilog para logging
