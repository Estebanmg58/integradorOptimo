# IntegradorOptimo - Worker Service .NET 8

Worker Service de Windows para sincronización automática de datos ERP ? API FondoSuma.

## ?? Características

- **Arquitectura**: 3 capas (Core, Infrastructure, Worker)
- **Sincronización programada** con Cron Expressions (NCrontab)
- **Procesamiento por lotes** configurable (default 500 registros)
- **Reintentos resilientes** con Polly (3 intentos + Circuit Breaker)
- **Logging profesional** con Serilog (archivos rotativos + consola)
- **Windows Service** nativo con .NET 8

## ??? Entidades Sincronizadas

| Entidad | Volumen Estimado | Timeout |
|---------|------------------|---------|
| Asociados | ~9,000 | 120s |
| Productos | ~14,000 | 120s |
| Movimientos | ~50,000-100,000 | 300s |
| Tasas | ~100 | 60s |
| Fecha Corte | 1 | 30s |

## ?? Instalación

### 1. Configurar Base de Datos

Ejecuta el script SQL en tu base de datos destino:

```sql
-- Ver: scripts/CreateIntegrationSettings.sql
```

Este script crea la tabla `IntegrationSettings` con la configuración inicial.

### 2. Configurar Conexiones

Edita `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "ErpDatabase": "Server=TU_SERVIDOR_ERP;Database=TU_BD_ERP;User Id=usuario;Password=contraseña;TrustServerCertificate=true;",
    "DestinationDatabase": "Server=TU_SERVIDOR_CONFIG;Database=TU_BD_CONFIG;User Id=usuario;Password=contraseña;TrustServerCertificate=true;"
  },
  "ApiSettings": {
    "BaseUrl": "https://api.fodnosuma.com",
    "JwtToken": "TU_TOKEN_JWT_AQUI"
  }
}
```

### 3. Compilar el Proyecto

```bash
dotnet build src/Integrador.Worker/Integrador.Worker.csproj -c Release
```

### 4. Publicar para Producción

```bash
dotnet publish src/Integrador.Worker/Integrador.Worker.csproj -c Release -o C:\IntegradorOptimo
```

### 5. Instalar como Windows Service

Abre PowerShell como Administrador:

```powershell
# Crear el servicio
sc.exe create IntegradorOptimo binPath="C:\IntegradorOptimo\Integrador.Worker.exe" start=auto

# Iniciar el servicio
sc.exe start IntegradorOptimo

# Verificar estado
sc.exe query IntegradorOptimo
```

## ?? Configuración

### Cron Expressions (ScheduleCron)

Ejemplos de configuración:

```sql
-- Diario a las 2:00 AM (default)
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 2 * * *'

-- Cada 4 horas
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 */4 * * *'

-- Lunes a viernes a las 8:00 AM
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 8 * * 1-5'

-- Cada 30 minutos
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '*/30 * * * *'
```

### Habilitar/Deshabilitar Entidades

```sql
-- Deshabilitar sincronización de Movimientos
EXEC sp_UpdateIntegrationSetting 'EnableMovimientos', 'false'

-- Habilitar de nuevo
EXEC sp_UpdateIntegrationSetting 'EnableMovimientos', 'true'
```

### Cambiar Tamaño de Lote

```sql
-- Lotes de 1000 registros
EXEC sp_UpdateIntegrationSetting 'BatchSize', '1000'
```

## ?? Logs

Los logs se generan en:
```
C:\Logs\IntegradorOptimo\log-YYYY-MM-DD.txt
```

**Retención**: 30 días (automático)

### Ejemplo de Log Exitoso

```
========================================
?? INICIANDO SINCRONIZACIÓN COMPLETA
========================================
?? Sincronizando Asociados...
   Total asociados obtenidos: 9000
   ? Batch 1/18: 500 registros en 450ms
   ? Batch 2/18: 500 registros en 430ms
   ...
   ? Asociados completados en 7.2s
?? Sincronizando Productos (FullLoad: True)...
   Total productos obtenidos: 14000
   ? Batch 1/28: 500 registros en 520ms
   ...
   ? Productos completados en 11.5s
?? Sincronizando Movimientos...
   Total movimientos obtenidos: 98543
   ? Batch 1/198: 500 registros en 380ms
   ...
   ? Movimientos completados en 23.8s
?? Sincronizando Tasas...
   ? Tasas completadas (100 registros) en 120ms
?? Sincronizando Fecha Corte...
   ? Fecha Corte actualizada: 2025-01-04 en 50ms
========================================
? SINCRONIZACIÓN COMPLETADA EN 42.7s
========================================
```

## ?? Comandos Útiles del Servicio

```powershell
# Ver estado
sc.exe query IntegradorOptimo

# Detener
sc.exe stop IntegradorOptimo

# Iniciar
sc.exe start IntegradorOptimo

# Reiniciar (detener + iniciar)
sc.exe stop IntegradorOptimo; sc.exe start IntegradorOptimo

# Eliminar servicio
sc.exe delete IntegradorOptimo

# Ver logs en tiempo real
Get-Content C:\Logs\IntegradorOptimo\log-*.txt -Tail 50 -Wait
```

## ??? Desarrollo Local

Para ejecutar en modo desarrollo:

```bash
cd src/Integrador.Worker
dotnet run
```

Para debug en Visual Studio:
1. Abrir `Integrador.sln`
2. Establecer `Integrador.Worker` como proyecto de inicio
3. Presionar F5

## ?? Estructura del Proyecto

```
Integrador.sln
??? src/
?   ??? Integrador.Core/
?   ?   ??? DTOs/
?   ?   ?   ??? AsociadoDto.cs
?   ?   ?   ??? ProductoDto.cs
?   ?   ?   ??? MovimientoDto.cs
?   ?   ?   ??? TasaDto.cs
?   ?   ?   ??? FechaCorteDto.cs
?   ?   ??? Models/
?   ?       ??? IntegrationSettings.cs
?   ??? Integrador.Infrastructure/
?   ?   ??? Repositories/
?   ?       ??? IIntegrationSettingsRepository.cs
?   ?       ??? IntegrationSettingsRepository.cs
?   ?       ??? IErpRepository.cs
?   ?       ??? ErpRepository.cs
?   ??? Integrador.Worker/
?       ??? Services/
?       ?   ??? IApiClientService.cs
?       ?   ??? ApiClientService.cs
?       ?   ??? PollyPolicies.cs
?       ??? IntegrationWorker.cs
?       ??? Program.cs
?       ??? appsettings.json
??? scripts/
    ??? CreateIntegrationSettings.sql
```

## ?? Requisitos del Stored Procedure ERP

El SP `ERP_SPConsultaDta` debe existir en la base de datos ERP y recibir el parámetro `@TipoConsulta`:

- **1**: Retorna Asociados
- **2**: Retorna Productos
- **3**: Retorna Movimientos
- **4**: Retorna Tasas
- **5**: Retorna Fecha Corte (un solo DateTime)

## ?? Endpoints de la API

El Worker envía datos a los siguientes endpoints:

- `POST /api/integration/asociados`
- `POST /api/integration/productos?isFullLoad={true/false}`
- `POST /api/integration/movimientos`
- `POST /api/integration/tasas`
- `POST /api/integration/fecha-corte`

Todos requieren:
- **Authorization**: Bearer {JwtToken}
- **Content-Type**: application/json

## ?? Políticas de Resiliencia

### Reintentos
- **Intentos**: 3
- **Backoff**: Exponencial (2s, 4s, 8s)
- **Aplica a**: Errores transitorios HTTP (5xx, timeout)

### Circuit Breaker
- **Fallos consecutivos**: 5
- **Tiempo abierto**: 30 segundos
- **Reevaluación**: Semi-abierto ? Cerrado si tiene éxito

## ?? Notas Importantes

1. **FullLoad de Productos**: Solo el primer batch del día (a la hora configurada en `DailyTruncateHour`) se marca con `isFullLoad=true`

2. **Memoria**: Para volúmenes >100K movimientos, se ejecuta GC cada 50 batches

3. **Timeouts**:
   - API: 5 minutos
   - SP Asociados/Productos: 120s
   - SP Movimientos: 300s (5min)
   - SP Tasas: 60s
   - SP Fecha Corte: 30s

4. **Zona horaria**: El Worker usa la hora local del servidor Windows

## ?? Troubleshooting

### El servicio no inicia
```powershell
# Ver logs del Event Viewer
Get-EventLog -LogName Application -Source IntegradorOptimo -Newest 10
```

### Cambiar configuración sin reiniciar
El Worker lee la configuración en cada ejecución programada, no requiere reinicio.

### Error de conexión a SQL
Verifica:
- Servidor accesible
- Credenciales correctas
- `TrustServerCertificate=true` en la cadena de conexión
- Puerto SQL Server (1433) abierto

### Error de autenticación API
Verifica:
- Token JWT válido y no expirado
- BaseUrl correcto
- Firewall permite salida HTTPS (443)

## ?? Licencia

Proyecto privado - FondoSuma © 2025

## ?? Autor

Desarrollado para FondoSuma
