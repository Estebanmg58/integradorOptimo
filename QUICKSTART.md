# ? Guía de Configuración Rápida - IntegradorOptimo

## ?? Setup en 5 Pasos

### 1?? Configurar Base de Datos

Ejecuta en SQL Server Management Studio (base de datos destino):

```sql
-- Abre y ejecuta: scripts/CreateIntegrationSettings.sql
```

### 2?? Configurar Credenciales

Edita `src/Integrador.Worker/appsettings.json`:

```json
{
  "ConnectionStrings": {
    "ErpDatabase": "Server=MI_SERVIDOR_ERP;Database=MI_BD_ERP;User Id=usuario;Password=pass;TrustServerCertificate=true;",
    "DestinationDatabase": "Server=MI_SERVIDOR_CONFIG;Database=MI_BD_CONFIG;User Id=usuario;Password=pass;TrustServerCertificate=true;"
  },
  "ApiSettings": {
    "BaseUrl": "https://api.fodnosuma.com",
    "JwtToken": "MI_TOKEN_JWT_REAL"
  }
}
```

### 3?? Verificar Stored Procedure ERP

Asegúrate de que existe en tu base de datos ERP:

```sql
-- Debe existir: ERP_SPConsultaDta
-- Parámetro: @TipoConsulta INT
-- Valores: 1=Asociados, 2=Productos, 3=Movimientos, 4=Tasas, 5=FechaCorte
```

### 4?? Probar Localmente

```powershell
cd src/Integrador.Worker
dotnet run
```

Deberías ver en la consola:
```
?? Integrador Óptimo iniciado - Servicio de Windows activo
? Próxima ejecución programada: 2025-01-05 02:00:00
```

### 5?? Instalar como Servicio de Windows

```powershell
# Abre PowerShell como ADMINISTRADOR
.\Install-Service.ps1 -Action install
```

---

## ? Verificación Post-Instalación

### Verificar estado del servicio
```powershell
.\Install-Service.ps1 -Action status
```

### Ver logs en tiempo real
```powershell
.\Install-Service.ps1 -Action logs
```

### Comandos rápidos
```powershell
# Detener
.\Install-Service.ps1 -Action stop

# Iniciar
.\Install-Service.ps1 -Action start

# Reiniciar
.\Install-Service.ps1 -Action restart
```

---

## ?? Configuración Avanzada

### Cambiar horario de sincronización

```sql
-- Ejecutar a las 3:00 AM en lugar de 2:00 AM
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 3 * * *'

-- Ejecutar cada 6 horas
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 */6 * * *'
```

### Ajustar tamaño de lote

```sql
-- Lotes más grandes para mejor performance (si la red lo permite)
EXEC sp_UpdateIntegrationSetting 'BatchSize', '1000'

-- Lotes más pequeños para conexiones lentas
EXEC sp_UpdateIntegrationSetting 'BatchSize', '200'
```

### Deshabilitar entidades temporalmente

```sql
-- No sincronizar Movimientos (por ejemplo, durante mantenimiento)
EXEC sp_UpdateIntegrationSetting 'EnableMovimientos', 'false'

-- Reactivar después
EXEC sp_UpdateIntegrationSetting 'EnableMovimientos', 'true'
```

---

## ?? Ejemplos de Cron

| Cron Expression | Descripción |
|----------------|-------------|
| `0 2 * * *` | Todos los días a las 2:00 AM |
| `0 */4 * * *` | Cada 4 horas |
| `0 0 * * 1` | Todos los lunes a medianoche |
| `*/30 * * * *` | Cada 30 minutos |
| `0 8-18 * * 1-5` | Lunes a viernes, cada hora de 8 AM a 6 PM |
| `0 0 1 * *` | Primer día de cada mes a medianoche |

---

## ?? Troubleshooting Rápido

### ? Error: "Cannot open database"
```
Verifica:
? Servidor SQL accesible
? Nombre de base de datos correcto
? Usuario tiene permisos
? TrustServerCertificate=true en connection string
```

### ? Error: "HTTP 401 Unauthorized"
```
Verifica:
? Token JWT válido y no expirado
? BaseUrl correcto (https://api.fodnosuma.com)
```

### ? Servicio no inicia
```powershell
# Ver errores en Event Viewer
Get-EventLog -LogName Application -Source "IntegradorOptimo" -Newest 10

# O revisar logs directamente
Get-Content C:\Logs\IntegradorOptimo\log-*.txt -Tail 50
```

### ?? Timeout al leer datos
```sql
-- Aumentar timeout en ErpRepository.cs si necesario
-- Por defecto: Asociados/Productos 120s, Movimientos 300s

-- O optimizar el SP en el ERP:
-- Crear índices en tablas consultadas
-- Evitar scans completos de tabla
```

---

## ?? Información de Contacto

**Proyecto**: IntegradorOptimo  
**Versión**: .NET 8  
**Framework**: Worker Service  

**Ubicaciones importantes**:
- Logs: `C:\Logs\IntegradorOptimo\`
- Instalación: `C:\IntegradorOptimo\`
- Configuración: `IntegrationSettings` en base de datos destino

---

## ?? ¡Listo para Producción!

Una vez configurado y probado:

1. ? El servicio se ejecuta automáticamente al iniciar Windows
2. ? Se reinicia automáticamente si falla
3. ? Logs rotativos (30 días de retención)
4. ? Reintentos con backoff exponencial
5. ? Circuit breaker para proteger la API
6. ? Configuración dinámica sin reiniciar servicio

**¡Todo melo caramelo, bro! ??**
