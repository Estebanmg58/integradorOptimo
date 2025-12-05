# ?? Guía de Troubleshooting - IntegradorOptimo

## ?? Problemas Comunes y Soluciones

---

## 1. PROBLEMAS DE INSTALACIÓN

### ? "Access Denied" al instalar el servicio

**Causa**: No tienes permisos de administrador

**Solución**:
```powershell
# Cierra PowerShell y ábrelo como Administrador
# Haz clic derecho en PowerShell ? "Ejecutar como administrador"
# Luego ejecuta:
.\Install-Service.ps1 -Action install
```

### ? "Cannot find path" al instalar

**Causa**: Estás en el directorio incorrecto

**Solución**:
```powershell
# Navega a la raíz del proyecto
cd C:\Users\TU_USUARIO\Source\Repos\integradorOptimo
# Verifica que veas el archivo
ls Install-Service.ps1
# Luego instala
.\Install-Service.ps1 -Action install
```

---

## 2. PROBLEMAS DE CONEXIÓN A BASE DE DATOS

### ? "Cannot open database" o "Login failed"

**Diagnóstico**:
```powershell
# Prueba la conexión con SQL Server Management Studio
# Usa las mismas credenciales del appsettings.json
```

**Soluciones**:

1. **Verificar servidor accesible**:
```powershell
Test-NetConnection -ComputerName TU_SERVIDOR_SQL -Port 1433
# Debe mostrar "TcpTestSucceeded : True"
```

2. **Verificar credenciales**:
```json
// En appsettings.json, asegúrate de:
{
  "ConnectionStrings": {
    "ErpDatabase": "Server=SERVIDOR_CORRECTO;Database=BD_CORRECTA;User Id=USUARIO;Password=PASSWORD;TrustServerCertificate=true;"
  }
}
```

3. **Verificar permisos del usuario SQL**:
```sql
-- En SQL Server, ejecuta como admin:
USE ErpDatabase;
GRANT SELECT ON SCHEMA::dbo TO tu_usuario;
GRANT EXECUTE ON dbo.ERP_SPConsultaDta TO tu_usuario;
```

### ? "A network-related or instance-specific error"

**Soluciones**:

1. **Habilitar TCP/IP en SQL Server**:
   - Abre SQL Server Configuration Manager
   - SQL Server Network Configuration ? Protocols
   - Habilita TCP/IP
   - Reinicia SQL Server Service

2. **Verificar Firewall**:
```powershell
# Permitir puerto 1433
New-NetFirewallRule -DisplayName "SQL Server" -Direction Inbound -Protocol TCP -LocalPort 1433 -Action Allow
```

3. **Usar IP en lugar de nombre**:
```json
"ErpDatabase": "Server=192.168.1.100;Database=ErpDB;..."
```

---

## 3. PROBLEMAS CON EL STORED PROCEDURE

### ? "Could not find stored procedure 'ERP_SPConsultaDta'"

**Verificación**:
```sql
-- Verifica que existe en la base de datos correcta
USE ErpDatabase;
GO

SELECT * FROM sys.procedures WHERE name = 'ERP_SPConsultaDta';
-- Debe retornar 1 fila
```

**Solución**:
```sql
-- Si no existe, créalo usando el ejemplo:
-- Abre y ejecuta: scripts/ERP_SPConsultaDta_Example.sql
-- Adapta a tu esquema de base de datos
```

### ? SP se ejecuta muy lento (Timeout)

**Diagnóstico**:
```sql
-- Mide tiempo de ejecución
SET STATISTICS TIME ON;
EXEC ERP_SPConsultaDta @TipoConsulta = 3; -- Movimientos (el más pesado)
SET STATISTICS TIME OFF;
```

**Soluciones**:

1. **Agregar índices**:
```sql
-- En tablas de Movimientos
CREATE NONCLUSTERED INDEX IX_Movimientos_Fecha 
ON dbo.Movimientos(FechaMovimiento) 
INCLUDE (DocumentoAsociado, CodigoProducto, ValorMovimiento);

-- En tablas de Asociados
CREATE NONCLUSTERED INDEX IX_Asociados_FechaAfiliacion 
ON dbo.Asociados(FechaAfiliacion) 
INCLUDE (DocumentoIdentidad, PrimerNombre, PrimerApellido);
```

2. **Aumentar timeout en código**:
```csharp
// En ErpRepository.cs, línea del SP de Movimientos:
var result = await connection.QueryAsync<MovimientoDto>(
    "ERP_SPConsultaDta",
    parameters,
    commandType: CommandType.StoredProcedure,
    commandTimeout: 600  // Cambiar de 300 a 600 segundos (10 min)
);
```

3. **Reducir rango de fechas**:
```sql
-- En el SP, cambiar de 3 meses a 1 mes:
WHERE m.FechaMovimiento >= DATEADD(MONTH, -1, GETDATE())
```

---

## 4. PROBLEMAS CON LA API

### ? "HTTP 401 Unauthorized"

**Causa**: Token JWT inválido o expirado

**Soluciones**:

1. **Verificar token válido**:
```powershell
# Pide un nuevo token al equipo de la API
# Actualiza appsettings.json:
```
```json
{
  "ApiSettings": {
    "JwtToken": "NUEVO_TOKEN_AQUI"
  }
}
```

2. **Reiniciar servicio**:
```powershell
.\Install-Service.ps1 -Action restart
```

### ? "HTTP 404 Not Found"

**Causa**: URL de la API incorrecta

**Solución**:
```json
// Verifica en appsettings.json:
{
  "ApiSettings": {
    "BaseUrl": "https://api.fodnosuma.com"  // Sin "/" al final
  }
}
```

### ? "HTTP 500 Internal Server Error"

**Causa**: Error en el servidor de la API

**Diagnóstico**:
```powershell
# Ver logs del Worker para detalles
.\Install-Service.ps1 -Action logs
```

**Solución**:
1. Contactar al equipo de la API
2. Revisar formato de datos enviados
3. Verificar que los DTOs coincidan con lo esperado por la API

### ? "Connection timed out" o "Task was canceled"

**Causa**: Red lenta o API no responde

**Soluciones**:

1. **Aumentar timeout del HttpClient**:
```csharp
// En ApiClientService.cs, constructor:
_httpClient.Timeout = TimeSpan.FromMinutes(10); // Cambiar de 5 a 10 min
```

2. **Reducir tamaño de lote**:
```sql
EXEC sp_UpdateIntegrationSetting 'BatchSize', '200'; -- De 500 a 200
```

3. **Verificar conectividad**:
```powershell
Test-NetConnection -ComputerName api.fodnosuma.com -Port 443
```

---

## 5. PROBLEMAS CON LOGS

### ? No se generan logs en C:\Logs\IntegradorOptimo\

**Causa**: Permisos de escritura

**Solución**:
```powershell
# Crear directorio manualmente
New-Item -ItemType Directory -Path "C:\Logs\IntegradorOptimo" -Force

# Dar permisos al servicio
icacls "C:\Logs\IntegradorOptimo" /grant "NT AUTHORITY\NETWORK SERVICE:(OI)(CI)F"
```

### ? Logs vacíos o sin detalles

**Causa**: Nivel de logging muy alto

**Solución**:
```json
// En appsettings.json, cambiar MinimumLevel:
{
  "Serilog": {
    "MinimumLevel": {
      "Default": "Debug",  // Cambiar de "Information" a "Debug"
      "Override": {
        "Microsoft": "Warning",
        "System": "Warning"
      }
    }
  }
}
```

---

## 6. PROBLEMAS CON EL SERVICIO DE WINDOWS

### ? Servicio no inicia (estado "Stopped")

**Diagnóstico**:
```powershell
# Ver errores en Event Viewer
Get-EventLog -LogName Application -Source "IntegradorOptimo" -Newest 10 | Format-List

# O ver logs directamente
Get-Content C:\Logs\IntegradorOptimo\log-*.txt -Tail 100
```

**Soluciones comunes**:

1. **Error de configuración**:
```powershell
# Verifica appsettings.json en:
notepad C:\IntegradorOptimo\appsettings.json
# Asegúrate de que no tenga errores de sintaxis JSON
```

2. **DLL faltante**:
```powershell
# Reinstala el servicio
.\Install-Service.ps1 -Action uninstall
.\Install-Service.ps1 -Action install
```

3. **Permisos insuficientes**:
```powershell
# Ejecuta el servicio como SYSTEM
sc.exe config IntegradorOptimo obj= LocalSystem
```

### ? Servicio se detiene inesperadamente

**Diagnóstico**:
```sql
-- Verifica configuración
SELECT * FROM IntegrationSettings;
```

**Soluciones**:

1. **Configurar reinicio automático**:
```powershell
# Ya está configurado en Install-Service.ps1, pero por si acaso:
sc.exe failure IntegradorOptimo reset= 86400 actions= restart/60000/restart/60000/restart/60000
```

2. **Revisar logs de excepción**:
```powershell
Get-Content C:\Logs\IntegradorOptimo\log-*.txt | Select-String -Pattern "ERROR|Exception"
```

---

## 7. PROBLEMAS DE RENDIMIENTO

### ? Sincronización toma mucho tiempo

**Diagnóstico**:
```powershell
# Ver logs de tiempos
Get-Content C:\Logs\IntegradorOptimo\log-*.txt | Select-String -Pattern "completados en"
```

**Optimizaciones**:

1. **Aumentar tamaño de lote** (si la red lo permite):
```sql
EXEC sp_UpdateIntegrationSetting 'BatchSize', '1000';
```

2. **Ejecutar en paralelo** (avanzado):
```csharp
// En IntegrationWorker.cs, método RunIntegrationAsync:
var tasks = new List<Task>();
if (settings.EnableAsociados) tasks.Add(SyncAsociadosAsync(...));
if (settings.EnableProductos) tasks.Add(SyncProductosAsync(...));
// ... etc
await Task.WhenAll(tasks);
```

3. **Optimizar SP del ERP**:
   - Agregar índices
   - Evitar SELECT *
   - Usar NOLOCK si aplica

### ? Alto uso de memoria

**Diagnóstico**:
```powershell
# Ver uso de memoria del proceso
Get-Process -Name "Integrador.Worker" | Select-Object WorkingSet64
```

**Solución**:
```sql
-- Reducir tamaño de lote
EXEC sp_UpdateIntegrationSetting 'BatchSize', '200';
```

```csharp
// En IntegrationWorker.cs, ya está implementado GC cada 50 batches
// Para movimientos grandes, el código hace GC.Collect() automáticamente
```

---

## 8. PROBLEMAS DE CRON EXPRESSION

### ? Servicio no ejecuta a la hora esperada

**Verificación**:
```sql
-- Ver configuración actual
SELECT SettingValue FROM IntegrationSettings WHERE SettingKey = 'ScheduleCron';
```

**Prueba de Cron**:
```powershell
# Usar herramienta online: https://crontab.guru/
# O probar expresión:
```
```csharp
// En C# Interactive:
using NCrontab;
var schedule = CrontabSchedule.Parse("0 2 * * *");
var next = schedule.GetNextOccurrence(DateTime.Now);
Console.WriteLine(next); // Ver cuándo sería la próxima ejecución
```

**Ejemplos correctos**:
```sql
-- Diario a las 2:00 AM
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 2 * * *';

-- Cada 4 horas
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 */4 * * *';

-- Cada 30 minutos (para pruebas)
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '*/30 * * * *';
```

---

## 9. VALIDACIÓN COMPLETA DEL SISTEMA

### ? Checklist de Verificación

```powershell
# 1. Verificar servicio instalado
sc.exe query IntegradorOptimo

# 2. Verificar conectividad a SQL ERP
Test-NetConnection -ComputerName TU_SERVIDOR_ERP -Port 1433

# 3. Verificar conectividad a SQL Destino
Test-NetConnection -ComputerName TU_SERVIDOR_DEST -Port 1433

# 4. Verificar conectividad a API
Test-NetConnection -ComputerName api.fodnosuma.com -Port 443

# 5. Verificar configuración
$config = Get-Content "C:\IntegradorOptimo\appsettings.json" | ConvertFrom-Json
$config.ConnectionStrings
$config.ApiSettings

# 6. Verificar logs
Get-ChildItem "C:\Logs\IntegradorOptimo\log-*.txt" | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# 7. Ver última ejecución
Get-Content C:\Logs\IntegradorOptimo\log-*.txt | Select-String -Pattern "SINCRONIZACIÓN COMPLETADA" | Select-Object -Last 1
```

---

## ?? SOPORTE DE EMERGENCIA

### Cuando nada más funciona:

1. **Reinicio completo**:
```powershell
.\Install-Service.ps1 -Action uninstall
dotnet clean
dotnet build -c Release
.\Install-Service.ps1 -Action install
```

2. **Ejecutar en modo consola para debug**:
```powershell
# Detener servicio
.\Install-Service.ps1 -Action stop

# Ejecutar manualmente en consola
cd C:\IntegradorOptimo
.\Integrador.Worker.exe

# Ver errores en tiempo real
```

3. **Logs detallados**:
```json
// Cambiar en appsettings.json temporalmente:
{
  "Serilog": {
    "MinimumLevel": {
      "Default": "Verbose"  // Máximo detalle
    }
  }
}
```

---

## ?? INFORMACIÓN DE CONTACTO

Si después de seguir esta guía aún tienes problemas:

1. Revisa los logs en `C:\Logs\IntegradorOptimo\`
2. Ejecuta el checklist de verificación completo
3. Documenta el error exacto (screenshot o texto completo)
4. Incluye la configuración relevante (sin passwords)

---

**Recuerda**: El 90% de los problemas se resuelven con:
- ? Verificar conexión a SQL Server
- ? Verificar token JWT válido
- ? Revisar logs detallados
- ? Reiniciar el servicio

¡Buena suerte! ??
