# ?? DOCUMENTACIÓN COMPLETA - IntegradorOptimo

## ?? ARCHIVOS INCLUIDOS

### ?? Documentación Principal

| Archivo | Descripción |
|---------|-------------|
| `README.md` | Este archivo - Índice general |
| `SETUP_GUIDE.md` | **Guía completa de instalación paso a paso** |
| `FULL_DATA_MIGRATION.md` | Explicación detallada de la migración de datos |
| `DATA_TYPES_MAPPING.md` | Mapeo completo de tipos de datos SQL Server ? C# |
| `API_PROMPT.md` | Prompt para crear la API de destino |
| `INSTALLATION_GUIDE.md` | Guía de instalación como servicio de Windows |

### ??? Scripts SQL

| Archivo | Propósito |
|---------|-----------|
| `scripts/01_CreateDatabase.sql` | **Crear IntegradorDB y configuración inicial** |
| `scripts/02_ConfigurationScripts.sql` | Scripts para configurar horarios y opciones |
| `scripts/03_PredefinedScenarios.sql` | 10 escenarios predefinidos listos para usar |

### ?? Configuración

| Archivo | Descripción |
|---------|-------------|
| `src/Integrador.Worker/appsettings.json` | Configuración actual (NO subir a Git) |
| `src/Integrador.Worker/appsettings.TEMPLATE.json` | Template de configuración con ejemplos |

---

## ?? INICIO RÁPIDO (5 MINUTOS)

### 1. Instalar .NET 8 Runtime

```powershell
# Descargar e instalar
https://dotnet.microsoft.com/download/dotnet/8.0/runtime

# Verificar
dotnet --version
# Debe mostrar: 8.0.x
```

### 2. Crear Base de Datos

Abre **SQL Server Management Studio (SSMS)** y ejecuta:

```sql
-- Ejecutar este script completo
-- C:\integradorOptimo\scripts\01_CreateDatabase.sql
```

### 3. Configurar Aplicación

```powershell
# 1. Copiar template
cd C:\integradorOptimo\src\Integrador.Worker
copy appsettings.TEMPLATE.json appsettings.json

# 2. Editar con tus credenciales
notepad appsettings.json

# 3. Compilar
cd C:\integradorOptimo
dotnet build -c Release

# 4. Probar
cd src\Integrador.Worker
dotnet run
```

### 4. Configurar Horario

```sql
-- Ejecutar cada 15 minutos (para pruebas)
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '*/15 * * * *';

-- Ver configuración
EXEC sp_ViewCurrentConfiguration;
```

### 5. Verificar Logs

```powershell
# Ver logs en tiempo real
Get-Content C:\integradorOptimo\src\Integrador.Worker\logs\log-*.txt -Tail 50 -Wait
```

---

## ?? GUÍAS DETALLADAS

### ?? Instalación Completa

Lee: **`SETUP_GUIDE.md`**

Incluye:
- ? Pre-requisitos
- ? Instalación paso a paso
- ? Configuración de base de datos
- ? Configuración de la aplicación
- ? Instalación como servicio de Windows
- ? Monitoreo
- ? Troubleshooting completo

### ?? Configurar Horarios

**Opción 1: Scripts Predefinidos**

```sql
-- Ejecutar: scripts/03_PredefinedScenarios.sql
-- Incluye 10 escenarios listos para usar:
-- 1. Producción Nocturna (2 AM diaria)
-- 2. Sincronización Frecuente (cada 4 horas)
-- 3. Desarrollo (cada 5 minutos)
-- 4. Pruebas de Performance
-- 5. Horas Laborales (Lun-Vie 8AM-6PM)
-- 6. Migración Inicial
-- 7. Mantenimiento
-- 8. Alta Disponibilidad (cada 15 min)
-- 9. Fin de Mes
-- 10. Personalizado
```

**Opción 2: Scripts Manuales**

```sql
-- Ver: scripts/02_ConfigurationScripts.sql
-- Incluye ejemplos de todos los horarios comunes
```

**Opción 3: Configuración Manual**

```sql
-- Diario a las 2 AM
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 2 * * *';

-- Cada 4 horas
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 */4 * * *';

-- Cada 30 minutos
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '*/30 * * * *';

-- Verificar
EXEC sp_ViewCurrentConfiguration;
```

### ?? Migración de Datos

Lee: **`FULL_DATA_MIGRATION.md`**

Incluye:
- Mapeo completo de campos
- Ejemplos de payloads
- Tipos de datos exactos
- Claves primarias y relaciones

Lee: **`DATA_TYPES_MAPPING.md`**

Incluye:
- Mapeo SQL Server ? C#
- Tabla completa campo por campo
- Ejemplos de conversiones
- Casos especiales

### ?? Configurar la API Destino

Lee: **`API_PROMPT.md`**

Prompt completo para crear la API que recibe los datos.

Incluye:
- DTOs completos
- Controladores
- Servicios
- Repositories con MERGE
- Table-Valued Parameters
- Middleware de autenticación

---

## ??? ESTRUCTURA DEL PROYECTO

```
integradorOptimo/
??? src/
?   ??? Integrador.Worker/          # Worker Service (aplicación principal)
?   ?   ??? IntegrationWorker.cs    # Lógica de sincronización
?   ?   ??? Services/               # Servicios (API Client, etc.)
?   ?   ??? appsettings.json        # Configuración actual
?   ?   ??? Program.cs              # Punto de entrada
?   ?
?   ??? Integrador.Core/            # DTOs y contratos
?   ?   ??? DTOs/                   # AsociadoDto, ProductoDto, etc.
?   ?
?   ??? Integrador.Infrastructure/  # Repositorios
?       ??? Repositories/           # ErpRepository, SettingsRepository
?
??? scripts/                        # Scripts SQL
?   ??? 01_CreateDatabase.sql      # Crear IntegradorDB
?   ??? 02_ConfigurationScripts.sql
?   ??? 03_PredefinedScenarios.sql
?
??? SETUP_GUIDE.md                  # Guía de instalación
??? FULL_DATA_MIGRATION.md
??? DATA_TYPES_MAPPING.md
??? API_PROMPT.md
??? README.md                       # Este archivo
```

---

## ?? CONFIGURACIÓN

### appsettings.json

```json
{
  "ConnectionStrings": {
    "ErpDatabase": "Server=TU_SERVIDOR;Database=TU_BD_ERP;...",
    "DestinationDatabase": "Server=TU_SERVIDOR;Database=IntegradorDB;..."
  },
  "ApiSettings": {
    "BaseUrl": "https://api.fondosuma.com",
    "ApiKey": "TU_API_KEY"
  }
}
```

Ver template completo: `src/Integrador.Worker/appsettings.TEMPLATE.json`

### Base de Datos (IntegradorDB)

```sql
-- Ver configuración actual
EXEC sp_ViewCurrentConfiguration;

-- Actualizar horario
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 2 * * *';

-- Activar/Desactivar entidades
EXEC sp_UpdateIntegrationSetting 'EnableProductos', 'true';

-- Cambiar tamaño de lote
EXEC sp_UpdateIntegrationSetting 'BatchSize', '500';
```

---

## ?? MONITOREO

### Ver Logs

```powershell
# Logs en tiempo real
Get-Content C:\IntegradorOptimo\logs\log-*.txt -Tail 50 -Wait

# Buscar errores
Get-Content C:\IntegradorOptimo\logs\log-*.txt | Select-String "ERROR"
```

### Ver Historial de Ejecuciones

```sql
-- Últimas 20 ejecuciones
SELECT TOP 20 * FROM vw_RecentExecutions ORDER BY Id DESC;

-- Ejecuciones exitosas
SELECT * FROM IntegrationExecutionHistory
WHERE Estado = 'Success'
ORDER BY FechaInicio DESC;

-- Estadísticas de performance
SELECT 
    COUNT(*) AS TotalEjecuciones,
    AVG(DuracionSegundos) AS PromedioSegundos,
    AVG(ProductosProcesados) AS PromedioProductos
FROM IntegrationExecutionHistory
WHERE Estado = 'Success'
  AND FechaInicio >= DATEADD(DAY, -7, GETDATE());
```

### Ver Estado del Servicio

```powershell
# Ver estado
sc.exe query IntegradorOptimo

# Ver logs de Windows
eventvwr.msc
# Buscar en: Windows Logs > Application > IntegradorOptimo
```

---

## ?? COMANDOS ÚTILES

### Servicio de Windows

```powershell
# Iniciar
sc.exe start IntegradorOptimo

# Detener
sc.exe stop IntegradorOptimo

# Reiniciar
sc.exe stop IntegradorOptimo
sc.exe start IntegradorOptimo

# Ver estado
sc.exe query IntegradorOptimo

# Ver configuración
sc.exe qc IntegradorOptimo
```

### Configuración SQL

```sql
-- Ver configuración actual
EXEC sp_ViewCurrentConfiguration;

-- Configuración rápida para PRODUCCIÓN
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 2 * * *';
EXEC sp_UpdateIntegrationSetting 'BatchSize', '500';
EXEC sp_UpdateIntegrationSetting 'EnableAsociados', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableProductos', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableMovimientos', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableTasas', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableFechaCorte', 'true';

-- Configuración rápida para PRUEBAS
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '*/15 * * * *';
EXEC sp_UpdateIntegrationSetting 'BatchSize', '100';
EXEC sp_UpdateIntegrationSetting 'EnableAsociados', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableProductos', 'false';
EXEC sp_UpdateIntegrationSetting 'EnableMovimientos', 'false';
```

---

## ?? CASOS DE USO COMUNES

### 1. Primera Instalación

```powershell
# 1. Instalar .NET 8
# 2. Ejecutar: scripts/01_CreateDatabase.sql
# 3. Configurar: appsettings.json
# 4. Compilar: dotnet build
# 5. Instalar servicio: sc.exe create ...
# 6. Iniciar: sc.exe start IntegradorOptimo
```

Ver guía completa: `SETUP_GUIDE.md`

### 2. Cambiar Horario

```sql
-- Cambiar a ejecución cada 4 horas
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '0 */4 * * *';
EXEC sp_ViewCurrentConfiguration;

-- Los cambios se aplican en la siguiente verificación (1 minuto)
-- Para aplicar inmediatamente: sc.exe stop/start IntegradorOptimo
```

### 3. Sincronizar Solo Una Entidad

```sql
-- Sincronizar SOLO Productos (para pruebas)
EXEC sp_UpdateIntegrationSetting 'EnableAsociados', 'false';
EXEC sp_UpdateIntegrationSetting 'EnableProductos', 'true';
EXEC sp_UpdateIntegrationSetting 'EnableMovimientos', 'false';
EXEC sp_UpdateIntegrationSetting 'EnableTasas', 'false';
EXEC sp_UpdateIntegrationSetting 'EnableFechaCorte', 'false';
```

### 4. Pausar Sincronización (Mantenimiento)

```sql
-- Deshabilitar TODO
EXEC sp_UpdateIntegrationSetting 'EnableAsociados', 'false';
EXEC sp_UpdateIntegrationSetting 'EnableProductos', 'false';
EXEC sp_UpdateIntegrationSetting 'EnableMovimientos', 'false';
EXEC sp_UpdateIntegrationSetting 'EnableTasas', 'false';
EXEC sp_UpdateIntegrationSetting 'EnableFechaCorte', 'false';

-- El servicio sigue ejecutándose pero no sincroniza nada
```

### 5. Ver Performance

```sql
-- Estadísticas de la última semana
SELECT 
    CAST(FechaInicio AS DATE) AS Dia,
    COUNT(*) AS Ejecuciones,
    AVG(DuracionSegundos) AS PromedioSegundos,
    SUM(ProductosProcesados) AS TotalProductos,
    AVG(ProductosProcesados) AS PromedioProductos
FROM IntegrationExecutionHistory
WHERE Estado = 'Success'
  AND FechaInicio >= DATEADD(DAY, -7, GETDATE())
GROUP BY CAST(FechaInicio AS DATE)
ORDER BY Dia DESC;
```

---

## ?? SEGURIDAD

### Recomendaciones

1. **NO** subir `appsettings.json` con credenciales reales a Git
2. Usar `appsettings.Production.json` para producción
3. Rotar la ApiKey periódicamente
4. Usar contraseñas fuertes en SQL Server
5. Configurar firewall para limitar acceso a SQL Server

### Variables de Entorno (Alternativa)

```powershell
# Configurar variables de entorno en Windows
setx ConnectionStrings__ErpDatabase "Server=...;Database=...;" /M
setx ApiSettings__ApiKey "TU_API_KEY" /M
```

---

## ?? TROUBLESHOOTING

Ver guía completa: **`SETUP_GUIDE.md`** > Sección "Troubleshooting"

### Problemas Comunes

| Problema | Solución |
|----------|----------|
| Servicio no inicia | Ver logs en `C:\IntegradorOptimo\logs\` |
| Error de conexión SQL | Verificar usuario/password en `appsettings.json` |
| Error 401 API | Verificar ApiKey correcta |
| No ejecuta a la hora programada | Verificar `ScheduleCron` con `sp_ViewCurrentConfiguration` |

---

## ?? SOPORTE

### Archivos de Documentación

- `SETUP_GUIDE.md` - Instalación completa
- `FULL_DATA_MIGRATION.md` - Migración de datos
- `DATA_TYPES_MAPPING.md` - Tipos de datos
- `API_PROMPT.md` - Configurar API destino

### Scripts SQL

- `scripts/01_CreateDatabase.sql` - Crear BD
- `scripts/02_ConfigurationScripts.sql` - Configuración
- `scripts/03_PredefinedScenarios.sql` - Escenarios predefinidos

### Logs

- Logs del Worker: `C:\IntegradorOptimo\logs\log-YYYY-MM-DD.txt`
- Event Viewer: `eventvwr.msc` > Windows Logs > Application

---

## ? CHECKLIST DE INSTALACIÓN

### Pre-Instalación
- [ ] .NET 8 Runtime instalado
- [ ] SQL Server accesible
- [ ] Permisos de administrador
- [ ] API Key obtenida

### Base de Datos
- [ ] IntegradorDB creada (`scripts/01_CreateDatabase.sql`)
- [ ] Configuración verificada (`sp_ViewCurrentConfiguration`)
- [ ] SP del ERP probado

### Aplicación
- [ ] Código descargado/clonado
- [ ] `appsettings.json` configurado
- [ ] Compilación exitosa (`dotnet build`)
- [ ] Prueba en debug exitosa (`dotnet run`)

### Servicio
- [ ] Aplicación publicada
- [ ] Servicio instalado (`sc.exe create`)
- [ ] Servicio iniciado (`sc.exe start`)
- [ ] Logs verificados

### Configuración
- [ ] Horario configurado
- [ ] Entidades activas configuradas
- [ ] Primera ejecución exitosa
- [ ] Monitoreo configurado

---

## ?? ¡TODO LISTO!

El Worker Service está configurado y listo para sincronizar datos automáticamente.

### Próximos Pasos

1. ? Monitorear la primera sincronización completa
2. ? Ajustar horarios según necesidad
3. ? Revisar logs periódicamente
4. ? Documentar cualquier ajuste personalizado

---

**Versión**: 1.0  
**Fecha**: Diciembre 2024  
**Estado**: ? Production Ready  

?? **IntegradorOptimo - Migración de datos automática entre ERP y FondoSuma** ??
