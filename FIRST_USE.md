# ?? PRIMER USO - IntegradorOptimo

## ¡Bienvenido! 

Este documento te guiará en tu **primera instalación** del IntegradorOptimo paso a paso.

---

## ? PRE-REQUISITOS

Antes de comenzar, asegúrate de tener:

- [ ] **Windows Server** (2016, 2019, 2022) o Windows 10/11 Pro
- [ ] **.NET 8 Runtime** instalado ([descargar aquí](https://dotnet.microsoft.com/download/dotnet/8.0))
- [ ] **SQL Server** accesible (para ERP y configuración)
- [ ] **Permisos de Administrador** en el servidor
- [ ] **Token JWT** de la API FondoSuma
- [ ] **Credenciales SQL** con permisos de lectura en ERP

Para verificar .NET 8:
```powershell
dotnet --version
# Debe mostrar: 8.x.x
```

---

## ?? INSTALACIÓN PASO A PASO

### PASO 1: Clonar/Copiar el Proyecto

```powershell
# Opción A: Desde Git
git clone https://github.com/Estebanmg58/integradorOptimo.git
cd integradorOptimo

# Opción B: Copiar archivos
# Copia toda la carpeta del proyecto a:
# C:\Projects\integradorOptimo
```

---

### PASO 2: Configurar Base de Datos Destino

**2.1. Conectarse a SQL Server Management Studio**

**2.2. Seleccionar la base de datos donde guardarás la configuración**  
(Puede ser una BD separada o la misma del ERP)

**2.3. Ejecutar el script de configuración**

```sql
-- Abre el archivo: scripts/CreateIntegrationSettings.sql
-- Selecciona todo (Ctrl+A)
-- Ejecuta (F5)

-- Verás mensajes como:
-- ? Tabla IntegrationSettings creada exitosamente
-- ? Configuración inicial insertada exitosamente
```

**2.4. Verificar que se creó correctamente**

```sql
SELECT * FROM IntegrationSettings;

-- Deberías ver 8 registros:
-- ScheduleCron, BatchSize, DailyTruncateHour, Enable[Entidades...]
```

---

### PASO 3: Verificar Stored Procedure del ERP

**3.1. Verificar que existe el SP**

```sql
USE TuBaseDatosERP;
GO

SELECT * FROM sys.procedures WHERE name = 'ERP_SPConsultaDta';

-- Si retorna 1 fila: ? Existe
-- Si retorna 0 filas: ? No existe
```

**3.2. Si no existe, crear uno de prueba**

```sql
-- Abre: scripts/ERP_SPConsultaDta_Example.sql
-- IMPORTANTE: Adapta los nombres de tablas a tu esquema real
-- Ejecuta el script
```

**3.3. Probar el SP**

```sql
-- Prueba cada tipo de consulta:
EXEC ERP_SPConsultaDta @TipoConsulta = 1;  -- Asociados
EXEC ERP_SPConsultaDta @TipoConsulta = 2;  -- Productos
EXEC ERP_SPConsultaDta @TipoConsulta = 3;  -- Movimientos
EXEC ERP_SPConsultaDta @TipoConsulta = 4;  -- Tasas
EXEC ERP_SPConsultaDta @TipoConsulta = 5;  -- Fecha Corte

-- Cada uno debe retornar datos
```

---

### PASO 4: Configurar Credenciales

**4.1. Abrir el archivo de configuración**

```powershell
notepad src\Integrador.Worker\appsettings.json
```

**4.2. Actualizar ConnectionStrings**

```json
{
  "ConnectionStrings": {
    "ErpDatabase": "Server=TU_SERVIDOR_ERP;Database=TU_BD_ERP;User Id=TU_USUARIO;Password=TU_PASSWORD;TrustServerCertificate=true;",
    "DestinationDatabase": "Server=TU_SERVIDOR_CONFIG;Database=TU_BD_CONFIG;User Id=TU_USUARIO;Password=TU_PASSWORD;TrustServerCertificate=true;"
  }
}
```

**Ejemplo real**:
```json
{
  "ConnectionStrings": {
    "ErpDatabase": "Server=192.168.1.10;Database=CoopDB;User Id=integrador_user;Password=P@ssw0rd123;TrustServerCertificate=true;",
    "DestinationDatabase": "Server=192.168.1.10;Database=IntegradorDB;User Id=integrador_user;Password=P@ssw0rd123;TrustServerCertificate=true;"
  }
}
```

**4.3. Actualizar ApiSettings**

```json
{
  "ApiSettings": {
    "BaseUrl": "https://api.fodnosuma.com",
    "JwtToken": "PEGA_AQUI_TU_TOKEN_JWT_REAL"
  }
}
```

**4.4. Guardar y cerrar**

---

### PASO 5: Probar Localmente

**5.1. Abrir PowerShell en la carpeta del proyecto**

```powershell
cd src\Integrador.Worker
```

**5.2. Ejecutar en modo desarrollo**

```powershell
dotnet run
```

**5.3. Verificar la salida**

Deberías ver algo como:

```
[10:30:15 INF] ?? Integrador Óptimo iniciado - Servicio de Windows activo
[10:30:15 INF] ? Próxima ejecución programada: 2025-01-05 02:00:00
```

**5.4. Para prueba inmediata, cambiar temporalmente el cron**

```sql
-- En SQL Server:
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '*/2 * * * *';
-- Esto ejecutará cada 2 minutos
```

```powershell
# Detener con Ctrl+C
# Volver a ejecutar
dotnet run

# En 2 minutos deberías ver:
# ?? INICIANDO SINCRONIZACIÓN COMPLETA
# ?? Sincronizando Asociados...
# etc...
```

**5.5. Revisar logs generados**

```powershell
# Los logs están en:
Get-Content logs\log-*.txt -Tail 50
```

**5.6. Si todo funciona, restablecer el cron**

```sql
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 2 * * *';
-- Volver a ejecución diaria a las 2 AM
```

---

### PASO 6: Instalar como Servicio de Windows

**6.1. Abrir PowerShell como ADMINISTRADOR**

```
Haz clic derecho en PowerShell ? "Ejecutar como administrador"
```

**6.2. Navegar a la carpeta del proyecto**

```powershell
cd C:\Projects\integradorOptimo
# (o donde hayas copiado el proyecto)
```

**6.3. Ejecutar el instalador**

```powershell
.\Install-Service.ps1 -Action install
```

Verás:

```
=========================================
?? INSTALACIÓN DE INTEGRADOR ÓPTIMO
=========================================
?? Compilando proyecto en modo Release...
?? Publicando aplicación en C:\IntegradorOptimo...
?? Creando directorio de logs: C:\Logs\IntegradorOptimo
??  Registrando servicio de Windows...
?? Configurando reinicio automático en caso de fallo...
??  Iniciando servicio...
=========================================
? INSTALACIÓN COMPLETADA EXITOSAMENTE
=========================================
```

---

### PASO 7: Verificar Instalación

**7.1. Ver estado del servicio**

```powershell
.\Install-Service.ps1 -Action status
```

Debe mostrar:
```
Estado:        Running
```

**7.2. Ver logs en tiempo real**

```powershell
.\Install-Service.ps1 -Action logs
```

Presiona `Ctrl+C` para salir.

**7.3. Ver en Servicios de Windows**

```powershell
# Abrir servicios
services.msc

# Buscar: IntegradorOptimo
# Debe estar: Iniciado, Automático
```

---

## ?? CONFIGURACIÓN INICIAL RECOMENDADA

### Para Ambiente de Pruebas

```sql
-- Ejecutar cada 10 minutos para pruebas rápidas
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '*/10 * * * *';

-- Lotes pequeños para ver más batches
EXEC sp_UpdateIntegrationSetting 'BatchSize', '100';

-- Solo habilitar Asociados inicialmente
EXEC sp_UpdateIntegrationSetting 'EnableAsociados', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableProductos', 'false';
EXEC sp_UpdateIntegrationSetting 'EnableMovimientos', 'false';
EXEC sp_UpdateIntegrationSetting 'EnableTasas', 'false';
EXEC sp_UpdateIntegrationSetting 'EnableFechaCorte', 'false';
```

### Para Producción

```sql
-- Ejecutar diariamente a las 2:00 AM
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 2 * * *';

-- Lotes de 500 (balance entre performance y memoria)
EXEC sp_UpdateIntegrationSetting 'BatchSize', '500';

-- Habilitar todas las entidades
EXEC sp_UpdateIntegrationSetting 'EnableAsociados', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableProductos', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableMovimientos', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableTasas', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableFechaCorte', 'true';

-- Productos FullLoad a las 2 AM
EXEC sp_UpdateIntegrationSetting 'DailyTruncateHour', '2';
```

---

## ?? MONITOREO POST-INSTALACIÓN

### Día 1: Verificar Primera Ejecución

```powershell
# Al día siguiente de instalar, revisar logs
Get-Content C:\Logs\IntegradorOptimo\log-*.txt | Select-String "SINCRONIZACIÓN COMPLETADA"

# Deberías ver:
# ? SINCRONIZACIÓN COMPLETADA EN XX.Xs
```

### Semana 1: Revisar Patrones

```sql
-- Verificar que los datos llegaron a la API
-- (consultar con el equipo de la API)
```

```powershell
# Revisar si hubo errores
Get-Content C:\Logs\IntegradorOptimo\log-*.txt | Select-String "ERROR|Exception"

# Si no hay resultados: ? Todo bien
```

### Mensual: Revisión de Logs

```powershell
# Ver tamaño de logs
Get-ChildItem C:\Logs\IntegradorOptimo\log-*.txt | 
    Measure-Object -Property Length -Sum | 
    Select-Object @{Name="Total (MB)";Expression={[math]::Round($_.Sum/1MB,2)}}

# Verificar que se están rotando correctamente (30 días max)
Get-ChildItem C:\Logs\IntegradorOptimo\log-*.txt | 
    Sort-Object LastWriteTime | 
    Select-Object Name, LastWriteTime, @{Name="Size (KB)";Expression={[math]::Round($_.Length/1KB,2)}}
```

---

## ?? ¿PROBLEMAS?

### El servicio no inicia

```powershell
# Ver detalles del error
.\Install-Service.ps1 -Action status

# Ver logs completos
Get-Content C:\Logs\IntegradorOptimo\log-*.txt -Tail 100
```

Ver **TROUBLESHOOTING.md** para soluciones detalladas.

### No se conecta a SQL Server

```powershell
# Probar conexión
Test-NetConnection -ComputerName TU_SERVIDOR -Port 1433
```

Ver **TROUBLESHOOTING.md** ? Sección 2.

### La API retorna 401

- Verificar que el token JWT es válido
- Pedir nuevo token si expiró
- Actualizar `appsettings.json` y reiniciar servicio

---

## ? CHECKLIST FINAL

Antes de cerrar este documento, verifica:

- [ ] Base de datos configurada con tabla `IntegrationSettings`
- [ ] SP `ERP_SPConsultaDta` existe y funciona
- [ ] `appsettings.json` con credenciales reales
- [ ] Prueba local exitosa con `dotnet run`
- [ ] Servicio instalado como `IntegradorOptimo`
- [ ] Estado del servicio: **Running**
- [ ] Logs generándose en `C:\Logs\IntegradorOptimo\`
- [ ] Primera ejecución programada configurada
- [ ] Documentación leída: README.md y QUICKSTART.md

---

## ?? PRÓXIMOS PASOS

1. **Leer QUICKSTART.md** - Configuración rápida
2. **Leer README.md** - Documentación completa
3. **Guardar TROUBLESHOOTING.md** - Para cuando lo necesites

---

## ?? ¡FELICIDADES!

Has instalado exitosamente el **IntegradorOptimo**.

El servicio ahora:
- ? Se ejecuta automáticamente según el cron configurado
- ? Se reinicia automáticamente si falla
- ? Genera logs detallados de cada sincronización
- ? Lee configuración dinámica sin reiniciar

**¡Todo listo para sincronizar datos como un profesional!** ??

---

**¿Dudas?** Consulta:
- ?? README.md
- ? QUICKSTART.md  
- ?? TROUBLESHOOTING.md
- ?? PROJECT_STRUCTURE.md

**¡Éxito en tu sincronización!** ??
