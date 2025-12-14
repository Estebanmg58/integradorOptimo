# ? QUICKSTART - IntegradorOptimo v1.2

**Instalación en 5 pasos** | Tiempo estimado: **15 minutos**

---

## ?? Pre-requisitos (verificar primero)

```powershell
# 1. Verificar .NET 8
dotnet --version
# Debe mostrar: 8.0.x

# 2. Verificar SQL Server accesible
Test-NetConnection -ComputerName TU_SERVIDOR_SQL -Port 1433

# 3. Verificar permisos de administrador
whoami /groups | Select-String "Administrators"
```

? **Todo OK?** ? Continúa

---

## ?? PASO 1: Clonar y Configurar (3 minutos)

```powershell
# Clonar repositorio
cd C:\Projects
git clone https://github.com/Estebanmg58/integradorOptimo.git
cd integradorOptimo

# Editar configuración
cd src\Integrador.Worker
notepad appsettings.json
```

**Pegar esta configuración (ajustar valores):**

```json
{
  "ConnectionStrings": {
    "ErpDatabase": "Server=192.168.1.10;Database=CoopDB;User Id=integrador;Password=TuPassword;TrustServerCertificate=true;",
    "DestinationDatabase": "Server=192.168.1.10;Database=IntegradorDB;User Id=integrador;Password=TuPassword;TrustServerCertificate=true;"
  },
  "ApiSettings": {
    "BaseUrl": "https://api.fondosuma.com",
    "ApiKey": "LlaveAuthApiKey-!@#"
  },
  "IntegrationSettings": {
    "ExecuteProcesoBeforeSync": true
  },
  "Serilog": {
    "MinimumLevel": {
      "Default": "Information"
    },
    "WriteTo": [
      {
        "Name": "File",
        "Args": {
          "path": "C:\\Logs\\IntegradorOptimo\\log-.txt",
          "rollingInterval": "Day",
          "retainedFileCountLimit": 30
        }
      },
      { "Name": "Console" }
    ]
  }
}
```

**Guardar:** `Ctrl+S` ? Cerrar

---

## ??? PASO 2: Configurar Base de Datos (5 minutos)

### 2.1. Crear BD de Configuración

```sql
-- En SSMS, conectarse al servidor
CREATE DATABASE IntegradorDB;
GO
USE IntegradorDB;
GO
```

### 2.2. Ejecutar Script

Abrir `scripts/CreateIntegrationSettings.sql` en SSMS y ejecutar (`F5`).

**Resultado esperado:**
```
? Tabla IntegrationSettings creada
? 8 registros insertados
```

### 2.3. Verificar SP "Proceso" en ERP

```sql
USE TuBaseDatosERP;  -- Ajustar nombre
GO

-- Verificar existencia
SELECT * FROM sys.procedures WHERE name = 'Proceso';
-- Debe retornar 1 fila

-- Dar permisos
GRANT EXECUTE ON Proceso TO integrador;  -- Ajustar usuario
```

---

## ?? PASO 3: Compilar y Probar (3 minutos)

```powershell
# Volver a la raíz del proyecto
cd C:\Projects\integradorOptimo

# Compilar
dotnet build -c Release

# Probar localmente
cd src\Integrador.Worker
dotnet run
```

**Salida esperada:**

```
[12:30:00 INF] ?? Integrador Óptimo iniciado
[12:30:00 INF] ?? Próxima ejecución: 2025-01-06 02:00:00
```

? **Funciona?** ? `Ctrl+C` para detener ? Continúa

? **Error?** ? Ver [Troubleshooting](#troubleshooting-rápido)

---

## ??? PASO 4: Instalar como Servicio (2 minutos)

```powershell
# Volver a la raíz
cd C:\Projects\integradorOptimo

# Publicar
dotnet publish src/Integrador.Worker/Integrador.Worker.csproj `
  -c Release `
  -r win-x64 `
  --self-contained false `
  -o C:\IntegradorOptimo

# Abrir PowerShell como ADMINISTRADOR

# Crear servicio
sc.exe create IntegradorOptimo `
  binPath= "C:\IntegradorOptimo\Integrador.Worker.exe" `
  start= auto `
  DisplayName= "Integrador Óptimo - FondoSuma"

# Configurar reinicio automático
sc.exe failure IntegradorOptimo reset= 86400 actions= restart/60000/restart/60000/restart/60000

# Iniciar
sc.exe start IntegradorOptimo

# Verificar
sc.exe query IntegradorOptimo
```

**Debe mostrar:**
```
STATE              : 4  RUNNING
```

? **Corriendo?** ? Continúa

---

## ?? PASO 5: Verificar Logs (2 minutos)

```powershell
# Ver logs en tiempo real
Get-Content C:\Logs\IntegradorOptimo\log-*.txt -Tail 50 -Wait
```

**Logs esperados (cuando ejecute a las 2 AM):**

```
[02:00:00 INF] ========================================
[02:00:00 INF] ?? INICIANDO SINCRONIZACIÓN COMPLETA
[02:00:00 INF] ========================================
[02:00:01 INF] ?? Ejecutando SP 'Proceso'...
[02:00:08 INF]    ? SP 'Proceso' completado en 7.3s
[02:00:09 INF] ?? Sincronizando Asociados...
[02:00:10 INF]    Total asociados obtenidos: 8,543
...
[02:00:15 INF] ?? Sincronizando Productos...
[02:00:16 WRN] Enviando TODOS los 14,328 productos en un solo lote...
[02:00:20 INF]    ? 14,328 productos enviados en 4.12s
[02:00:20 INF]    ?? Performance: 3478 registros/segundo
...
[02:00:25 INF] ========================================
[02:00:25 INF] ? SINCRONIZACIÓN COMPLETADA EN 24.3s
[02:00:25 INF] ========================================
```

---

## ? CHECKLIST FINAL

- [ ] **.NET 8** instalado y verificado
- [ ] **SQL Server** accesible desde el servidor
- [ ] **IntegradorDB** creada con tabla `IntegrationSettings`
- [ ] **SP Proceso** verificado con permisos
- [ ] **appsettings.json** configurado con credenciales reales
- [ ] **Compilación** exitosa
- [ ] **Prueba local** exitosa
- [ ] **Servicio instalado** y corriendo
- [ ] **Logs** generándose en `C:\Logs\IntegradorOptimo\`
- [ ] **SP Proceso** ejecutándose en logs
- [ ] **Productos** enviados de una vez (no batches)

---

## ?? PRUEBA INMEDIATA (Opcional)

**No quieres esperar hasta las 2 AM?**

```sql
-- Cambiar cron para ejecutar cada 2 minutos
UPDATE IntegrationSettings 
SET SettingValue = '*/2 * * * *' 
WHERE SettingKey = 'ScheduleCron';

-- El Worker leerá esto automáticamente
-- En 2 minutos verás la sincronización en logs
```

**Después de probar, restablecer:**

```sql
UPDATE IntegrationSettings 
SET SettingValue = '0 2 * * *'  -- Volver a 2 AM diario
WHERE SettingKey = 'ScheduleCron';
```

---

## ?? TROUBLESHOOTING RÁPIDO

### Error: "dotnet: command not found"

**Solución:**
```powershell
# Instalar .NET 8 Runtime
# https://dotnet.microsoft.com/download/dotnet/8.0
```

### Error: "Cannot open database 'IntegradorDB'"

**Solución:**
```sql
-- Verificar que la BD existe
SELECT name FROM sys.databases WHERE name = 'IntegradorDB';

-- Si no existe, crearla:
CREATE DATABASE IntegradorDB;
```

### Error: "Could not find stored procedure 'Proceso'"

**Solución Temporal (NO en producción):**
```json
// En appsettings.json:
"ExecuteProcesoBeforeSync": false
```

**Solución Permanente:**
```sql
-- Verificar en BD ERP
USE TuBD_ERP;
SELECT * FROM sys.procedures WHERE name = 'Proceso';

-- Si no existe, contactar equipo ERP
```

### Error: "401 Unauthorized" en API

**Solución:**
```json
// Verificar ApiKey en appsettings.json:
"ApiKey": "LlaveAuthApiKey-!@#"  // Exactamente este valor
```

### Error: Servicio no inicia

**Diagnóstico:**
```powershell
# Ver logs de Windows
Get-EventLog -LogName Application -Source "IntegradorOptimo" -Newest 10

# Ver logs de la aplicación
Get-Content C:\Logs\IntegradorOptimo\log-*.txt -Tail 100
```

**Solución común:**
```powershell
# Dar permisos al directorio de logs
icacls "C:\Logs\IntegradorOptimo" /grant "NT AUTHORITY\NETWORK SERVICE:(OI)(CI)F"

# Reiniciar servicio
sc.exe stop IntegradorOptimo
sc.exe start IntegradorOptimo
```

---

## ?? PRÓXIMOS PASOS

### Configurar Programación

```sql
-- Ejecutar cada 30 minutos
UPDATE IntegrationSettings 
SET SettingValue = '*/30 * * * *' 
WHERE SettingKey = 'ScheduleCron';

-- Ejecutar diariamente a las 3 AM
UPDATE IntegrationSettings 
SET SettingValue = '0 3 * * *' 
WHERE SettingKey = 'ScheduleCron';
```

**Cron Helper:** [crontab.guru](https://crontab.guru/)

### Configurar Lotes

```sql
-- Aumentar tamaño de lote (si tienes buen hardware)
UPDATE IntegrationSettings 
SET SettingValue = '1000' 
WHERE SettingKey = 'BatchSize';

-- Reducir (si hay problemas de memoria)
UPDATE IntegrationSettings 
SET SettingValue = '250' 
WHERE SettingKey = 'BatchSize';
```

**Nota:** Los productos SIEMPRE se envían completos (ignora BatchSize).

### Habilitar/Deshabilitar Entidades

```sql
-- Deshabilitar movimientos temporalmente
UPDATE IntegrationSettings 
SET SettingValue = 'false' 
WHERE SettingKey = 'EnableMovimientos';

-- Habilitar de nuevo
UPDATE IntegrationSettings 
SET SettingValue = 'true' 
WHERE SettingKey = 'EnableMovimientos';
```

---

## ?? Documentación Completa

| Documento | Cuándo leerlo |
|-----------|---------------|
| [INSTALLATION_GUIDE_V1.2.md](./INSTALLATION_GUIDE_V1.2.md) | Instalación detallada paso a paso |
| [CAMBIOS_CRITICOS_V1.2.md](./CAMBIOS_CRITICOS_V1.2.md) | Entender cambios en v1.2 |
| [README_V1.2.md](./README_V1.2.md) | Visión general del proyecto |
| [TROUBLESHOOTING.md](./TROUBLESHOOTING.md) | Solución de problemas avanzados |

---

## ?? Soporte

**¿Problemas?**

1. Revisar logs: `C:\Logs\IntegradorOptimo\log-*.txt`
2. Buscar errores: `Select-String "ERROR|Exception"`
3. Consultar [TROUBLESHOOTING.md](./TROUBLESHOOTING.md)
4. Abrir issue en GitHub

---

## ?? ¡LISTO!

Tu **IntegradorOptimo v1.2** está instalado y funcionando.

**Verificar:**
- ? Servicio corriendo: `sc.exe query IntegradorOptimo`
- ? Logs generándose: `ls C:\Logs\IntegradorOptimo\`
- ? SP Proceso ejecutándose: Buscar en logs `?? Ejecutando SP 'Proceso'`
- ? Performance brutal: Buscar `?? Performance: xxx registros/segundo`

---

**Tiempo total de instalación**: ~15 minutos  
**Performance esperado**: <30 segundos por sincronización completa  

?? **¡TODO MELO CARAMELO!** ??
