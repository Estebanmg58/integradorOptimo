# ?? Guía de Despliegue a Producción - IntegradorOptimo

## ?? PROBLEMA ACTUAL: El servicio se cierra inmediatamente

### Causa Probable
La tabla `IntegrationSettings` NO existe en la base de datos `FMSRV-FONDOSUMA\dbIntegra`.

### ? SOLUCIÓN INMEDIATA

#### 1?? **Crear la tabla IntegrationSettings en la BD**

Conecta a SQL Server Management Studio y ejecuta:

```sql
USE dbIntegra;
GO

-- Crear tabla de configuración
CREATE TABLE [dbo].[IntegrationSettings] (
    [Id] INT PRIMARY KEY IDENTITY(1,1),
    [SettingKey] NVARCHAR(100) NOT NULL UNIQUE,
    [SettingValue] NVARCHAR(500) NOT NULL,
    [LastModified] DATETIME2 DEFAULT GETDATE(),
    [Description] NVARCHAR(500) NULL
);
GO

-- Insertar configuración inicial
INSERT INTO [dbo].[IntegrationSettings] ([SettingKey], [SettingValue], [Description])
VALUES
    ('ScheduleCron', '0 2 * * *', 'Ejecutar a las 2 AM todos los días'),
    ('BatchSize', '500', 'Tamaño de lote para procesamiento'),
    ('DailyTruncateHour', '2', 'Hora para carga completa (TRUNCATE)'),
    ('EnableAsociados', 'true', 'Sincronizar Asociados'),
    ('EnableProductos', 'true', 'Sincronizar Productos'),
    ('EnableMovimientos', 'true', 'Sincronizar Movimientos'),
    ('EnableTasas', 'true', 'Sincronizar Tasas'),
    ('EnableFechaCorte', 'true', 'Sincronizar Fecha Corte');
GO

-- Verificar
SELECT * FROM [dbo].[IntegrationSettings];
GO
```

#### 2?? **Verificar Logs**

Revisa el archivo de log para ver el error exacto:

```
C:\HostingSpace\IntegradorNuevaVersion\Logs\log-20251214.txt
```

Busca líneas con `[ERR]` o `Error` para identificar el problema.

---

## ?? Checklist Completo de Despliegue

### ? Configuración Actual (ya aplicada)

| Item | Valor |
|------|-------|
| **Base de Datos** | `FMSRV-FONDOSUMA\dbIntegra` |
| **API URL** | `https://fondosuma.com.co/API` |
| **API Key** | `f3a7c9e1-d5b2-4f8a-9c3e-1b7d4f6a8e2c` |
| **Logs** | `C:\HostingSpace\IntegradorNuevaVersion\Logs\` |

### ? Requisitos en Base de Datos

**Tablas requeridas:**
- ? `IMPRIME` (ya debe existir)
- ? `CodigosBarras` (ya debe existir)
- ?? `IntegrationSettings` (CREAR con el script de arriba)

**Stored Procedures requeridos:**
- ? `Proceso` (debe existir)
- ? `ERP_SPConsultaDta` (debe existir)

---

## ?? Comandos Útiles

### Gestión del Servicio Windows

```powershell
# Ver estado
sc.exe query IntegradorOptimo

# Detener
sc.exe stop IntegradorOptimo

# Iniciar
sc.exe start IntegradorOptimo

# Reiniciar (detener + iniciar)
sc.exe stop IntegradorOptimo && timeout /t 2 && sc.exe start IntegradorOptimo

# Eliminar servicio (si necesitas reinstalar)
sc.exe delete IntegradorOptimo

# Instalar nuevamente
sc.exe create "IntegradorOptimo" binPath= "C:\HostingSpace\IntegradorNuevaVersion\Integrador.Worker.exe" start= auto DisplayName= "Integrador Optimo FondoSuma"
```

### Ver Logs en Tiempo Real

```powershell
# Ver últimas 20 líneas
Get-Content C:\HostingSpace\IntegradorNuevaVersion\Logs\log-*.txt -Tail 20 -Wait

# Buscar errores
Select-String -Path C:\HostingSpace\IntegradorNuevaVersion\Logs\log-*.txt -Pattern "Error|Exception" -Context 2,2
```

---

## ?? Prueba Manual (SIN Servicio de Windows)

Para probar si funciona correctamente antes de instalar como servicio:

### **Opción 1: Usando el archivo .bat (RECOMENDADO)**

```powershell
# Copiar RUN_WORKER.bat junto con los demás archivos al servidor
# Luego ejecutar:
cd C:\HostingSpace\IntegradorNuevaVersion
.\RUN_WORKER.bat
```

El archivo `.bat` hace que la consola se mantenga abierta incluso si hay errores.

### **Opción 2: PowerShell con pausa**

```powershell
cd C:\HostingSpace\IntegradorNuevaVersion
.\Integrador.Worker.exe ; pause
```

### **Opción 3: CMD con pausa**

```cmd
cd C:\HostingSpace\IntegradorNuevaVersion
Integrador.Worker.exe
pause
```

### **Lo que DEBES ver:**

```
========================================
?? INICIANDO IntegradorOptimo Worker Service
========================================
Presiona Ctrl+C para detener el servicio
========================================

? Serilog configurado correctamente
? Windows Service configurado
? Connection strings loaded
? Repositories registered
? HTTP Client configured
? Worker Service registered
========================================
? Host built successfully - Starting application
========================================

[INF] ?? Integrador Óptimo iniciado - Servicio de Windows activo
[INF] ? Próxima ejecución programada: 2025-12-15 02:00:00
```

Si ves esto, **el Worker está funcionando correctamente** ?

### **Si hay error:**

Verás el error completo en **ROJO** con:
- Tipo de excepción
- Mensaje de error
- Stack trace completo
- "Presiona cualquier tecla para salir..." (la consola NO se cerrará hasta que presiones una tecla)

---

## ?? Diagnóstico de Problemas Comunes

### Problema 1: Se cierra inmediatamente
**Causa:** No puede conectarse a la base de datos o falta la tabla `IntegrationSettings`
**Solución:** Ejecutar el script SQL de arriba

### Problema 2: Error de autenticación SQL
**Causa:** `Integrated Security=True` requiere que el usuario de Windows tenga acceso
**Solución:** 
```json
// Cambiar en appsettings.json a credenciales SQL:
"ErpDatabase": "Data Source=FMSRV-FONDOSUMA;Initial Catalog=dbIntegra;User Id=usuario_sql;Password=contraseña;Encrypt=False"
```

### Problema 3: No puede escribir logs
**Causa:** No existe la carpeta o no tiene permisos
**Solución:**
```powershell
# La carpeta Logs se crea automáticamente en el directorio del ejecutable
# Si aún así no funciona, verificar permisos:
icacls C:\HostingSpace\IntegradorNuevaVersion\Logs /grant "NT AUTHORITY\NETWORK SERVICE:(OI)(CI)F"
```

### Problema 4: "Cannot find stored procedure 'ERP_SPConsultaDta'"
**Causa:** El SP no existe en la BD origen
**Solución:** Verificar que todos los SPs existan:
```sql
SELECT name FROM sys.objects WHERE type = 'P' AND name LIKE '%ERP%'
```

---

## ? Verificación Final

Cuando el servicio esté funcionando correctamente, deberías ver:

1. **En logs** (`C:\HostingSpace\IntegradorNuevaVersion\Logs\log-YYYYMMDD.txt`):
```
[INF] ?? Integrador Óptimo iniciado - Servicio de Windows activo
[INF] ? Próxima ejecución programada: 2025-12-15 02:00:00
```

2. **En servicio**:
```powershell
sc.exe query IntegradorOptimo
# Estado: RUNNING
```

3. **En base de datos**:
```sql
SELECT TOP 10 * FROM IntegrationSettings ORDER BY LastModified DESC
```

---

## ?? Contacto

Si persiste el problema, revisa los logs y envía:
1. El contenido del archivo de log más reciente
2. El resultado de `sc.exe query IntegradorOptimo`
3. El resultado de `SELECT * FROM IntegrationSettings`
