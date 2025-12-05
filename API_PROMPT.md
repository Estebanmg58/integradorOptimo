# 🎯 PROMPT PARA CREAR LA API DE RECEPCIÓN DE DATOS

## 📋 CONTEXTO

Necesito crear un conjunto de controladores y servicios en **ASP.NET Core (.NET 8) Web API** para recibir datos de migración desde un sistema ERP. Los datos vienen de un **Worker Service** que envía información en lotes (batches) de 500 registros usando HttpClient.

**IMPORTANTE**: Las tablas ya existen en la base de datos destino con exactamente el mismo esquema que las tablas origen. NO crear nuevas tablas. Solo implementar la lógica de INSERT/UPDATE (UPSERT) sobre las tablas existentes.

---

## 🔐 AUTENTICACIÓN

La API usa **API Key** en el header `X-API-Key` con valor: `LlaveAuthApiKey-!@#`

Implementa un **middleware** o **attribute filter** para validar este header en todos los endpoints del controlador de integración.

Ejemplo de validación:
```csharp
if (httpContext.Request.Headers["X-API-Key"] != "LlaveAuthApiKey-!@#")
{
    httpContext.Response.StatusCode = 401;
    await httpContext.Response.WriteAsync("Unauthorized: Invalid API Key");
    return;
}
```

---

## 🌐 ENDPOINTS REQUERIDOS

Todos los endpoints son **POST** y siguen el patrón: `/api/integration/{entidad}`

### 1. POST /api/integration/asociados
**Request Body**: `List<AsociadoDto>` (hasta 500 items por batch)
**Descripción**: Recibe asociados (socios/clientes) para insertar o actualizar.
**Clave única**: `Tercero` (bigint)

### 2. POST /api/integration/productos
**Request Body**: `List<ProductoDto>` (hasta 500 items por batch)
**Query Param**: `isFullLoad` (bool, default: false)
- `true`: Primera carga del día (opcional: truncar antes de insertar)
- `false`: Carga incremental (solo INSERT/UPDATE)
**Clave única**: `Consecutivo` (varchar(15))

### 3. POST /api/integration/movimientos
**Request Body**: `List<MovimientoDto>` (hasta 500 items por batch)
**Descripción**: Recibe movimientos (transacciones) para insertar o actualizar.
**Clave única**: `Id` (int)

### 4. POST /api/integration/tasas
**Request Body**: `List<TasaDto>` (usualmente <100 items)
**Descripción**: Recibe tasas de interés para insertar o actualizar.
**Clave compuesta**: `CodigoEntidad + CodigoProducto + CodigoLinea + PlazoInicial + PlazoFinal`

### 5. POST /api/integration/fecha-corte
**Request Body**: `FechaCorteDto` (objeto único)
**Descripción**: Actualiza la fecha de corte en una tabla de configuración o en `admEntidades`.

---

## 📦 MODELOS DE DATOS (DTOs)

Usa **exactamente** estos DTOs (copiar tal cual):

### AsociadoDto.cs
```csharp
namespace TuApi.DTOs;

public class AsociadoDto
{
    public short CodigoEntidad { get; set; }           // smallint NOT NULL
    public long Tercero { get; set; }                  // bigint NOT NULL - CLAVE ÚNICA
    public short CodigoOficina { get; set; }           // smallint NOT NULL
    public string Documento { get; set; } = string.Empty;      // varchar(15) NOT NULL
    public string PrimerNombre { get; set; } = string.Empty;   // varchar(20) NOT NULL
    public string? SegundoNombre { get; set; }         // varchar(20) NULL
    public string PrimerApellido { get; set; } = string.Empty; // varchar(20) NOT NULL
    public string? SegundoApellido { get; set; }       // varchar(20) NULL
    public short? Antiguedad { get; set; }             // smallint NULL
    public string? Email { get; set; }                 // varchar(100) NULL
    public string? Celular { get; set; }               // varchar(12) NULL
    public short? Estado { get; set; }                 // smallint NULL
    public DateTime? FechaMatricula { get; set; }      // smalldatetime NULL
}
```

### ProductoDto.cs
```csharp
namespace TuApi.DTOs;

public class ProductoDto
{
    public short CodigoEntidad { get; set; }           // smallint NOT NULL
    public short CodigoOficina { get; set; }           // smallint NOT NULL
    public short CodigoProducto { get; set; }          // smallint NOT NULL
    public string Consecutivo { get; set; } = string.Empty;    // varchar(15) NOT NULL - CLAVE
    public long Tercero { get; set; }                  // bigint NOT NULL - FK a Asociado
    public string? CodigoLinea { get; set; }           // varchar(10) NULL
    public short? Digito { get; set; }                 // smallint NULL
    public decimal? Monto { get; set; }                // money NULL
    public decimal? Saldo { get; set; }                // money NULL
    public decimal? Cuota { get; set; }                // money NULL
    public int? Pagare { get; set; }                   // int NULL
    public short? Plazo { get; set; }                  // smallint NULL
    public short? CuotasPagas { get; set; }            // smallint NULL
    public short? CuotasMora { get; set; }             // smallint NULL
    public DateTime? FechaUltimaTrans { get; set; }    // datetime NULL
    public DateTime? FechaVencimiento { get; set; }    // datetime NULL
    public short? Estado { get; set; }                 // smallint NULL
    public DateTime? FechaApertura { get; set; }       // datetime NULL
    public DateTime? FechaRetiro { get; set; }         // datetime NULL
}
```

### MovimientoDto.cs
```csharp
namespace TuApi.DTOs;

public class MovimientoDto
{
    public int Id { get; set; }                        // int NOT NULL - CLAVE ÚNICA
    public short CodigoEntidad { get; set; }           // smallint NOT NULL
    public short CodigoOficina { get; set; }           // smallint NOT NULL
    public short CodigoProducto { get; set; }          // smallint NOT NULL
    public string Consecutivo { get; set; } = string.Empty;    // varchar(15) NOT NULL - FK
    public DateTime Fecha { get; set; }                // datetime NOT NULL
    public string Operacion { get; set; } = string.Empty;      // varchar(25) NOT NULL
    public short Naturaleza { get; set; }              // smallint NOT NULL
    public decimal Valor { get; set; }                 // money NOT NULL
    public short? Cuota { get; set; }                  // smallint NULL
}
```

### TasaDto.cs
```csharp
namespace TuApi.DTOs;

public class TasaDto
{
    public short CodigoEntidad { get; set; }           // smallint NOT NULL
    public short CodigoProducto { get; set; }          // smallint NOT NULL
    public string CodigoLinea { get; set; } = string.Empty;    // varchar(6) NOT NULL
    public short PlazoInicial { get; set; }            // smallint NOT NULL
    public short PlazoFinal { get; set; }              // smallint NOT NULL
    public decimal MontoInicial { get; set; }          // money NOT NULL
    public decimal MontoFinal { get; set; }            // money NOT NULL
    public double Tasa { get; set; }                   // float NOT NULL
}
```

### FechaCorteDto.cs
```csharp
namespace TuApi.DTOs;

public class FechaCorteDto
{
    public DateTime? FechaCorte { get; set; }          // smalldatetime NULL
}
```

---

## 🗄️ TABLAS EXISTENTES EN BASE DE DATOS

**IMPORTANTE**: Las tablas YA EXISTEN con este esquema. NO crear nuevas tablas.

### Tabla: genAsociados
```sql
-- Ya existe con estos campos (puede tener más, pero estos son los que actualizamos):
CodigoEntidad smallint NOT NULL
Tercero bigint NOT NULL PRIMARY KEY
CodigoOficina smallint NOT NULL
Documento varchar(15) NOT NULL
PrimerNombre varchar(20) NOT NULL
SegundoNombre varchar(20) NULL
PrimerApellido varchar(20) NOT NULL
SegundoApellido varchar(20) NULL
Antiguedad smallint NULL
Email varchar(100) NULL
Celular varchar(12) NULL
Estado smallint NULL
FechaMatricula smalldatetime NULL
```

### Tabla: genProductos
```sql
-- Ya existe con estos campos (puede tener más, pero estos son los que actualizamos):
CodigoEntidad smallint NOT NULL
CodigoOficina smallint NOT NULL
CodigoProducto smallint NOT NULL
Consecutivo varchar(15) NOT NULL PRIMARY KEY
Tercero bigint NOT NULL
CodigoLinea varchar(10) NULL
Digito smallint NULL
Monto money NULL
Saldo money NULL
Cuota money NULL
Pagare int NULL
Plazo smallint NULL
CuotasPagas smallint NULL
CuotasMora smallint NULL
FechaUltimaTrans datetime NULL
FechaVencimiento datetime NULL
Estado smallint NULL
FechaApertura datetime NULL
FechaRetiro datetime NULL
```

### Tabla: genMovimiento
```sql
-- Ya existe con estos campos:
id int NOT NULL PRIMARY KEY
CodigoEntidad smallint NOT NULL
CodigoOficina smallint NOT NULL
CodigoProducto smallint NOT NULL
Consecutivo varchar(15) NOT NULL
Fecha datetime NOT NULL
Operacion varchar(25) NOT NULL
Naturaleza smallint NOT NULL
Valor money NOT NULL
Cuota smallint NULL
```

### Tabla: admTasas
```sql
-- Ya existe con estos campos:
CodigoEntidad smallint NOT NULL
CodigoProducto smallint NOT NULL
CodigoLinea varchar(6) NOT NULL
PlazoInicial smallint NOT NULL
PlazoFinal smallint NOT NULL
MontoInicial money NOT NULL
MontoFinal money NOT NULL
Tasa float NOT NULL
-- Clave primaria compuesta en estos 5 campos
```

### Tabla: admEntidades (para FechaCorte)
```sql
-- Ya existe, actualizar solo el campo FechaCorte donde id = 1
id int PRIMARY KEY
FechaCorte smalldatetime NULL
-- (puede tener más campos)
```

---

## ⚙️ REQUISITOS DE IMPLEMENTACIÓN

### 1. Arquitectura (Patrón Repository + Service)

```
Controllers/
├── IntegrationController.cs          // Controlador con los 5 endpoints

Services/
├── IIntegrationService.cs            // Interface del servicio
├── IntegrationService.cs             // Implementación del servicio

Repositories/
├── IAsociadoRepository.cs            // Interfaces por entidad
├── IProductoRepository.cs
├── IMovimientoRepository.cs
├── ITasaRepository.cs
├── IConfiguracionRepository.cs
├── AsociadoRepository.cs             // Implementaciones con Dapper
├── ProductoRepository.cs
├── MovimientoRepository.cs
├── TasaRepository.cs
├── ConfiguracionRepository.cs

DTOs/
├── AsociadoDto.cs
├── ProductoDto.cs
├── MovimientoDto.cs
├── TasaDto.cs
├── FechaCorteDto.cs

Middleware/
├── ApiKeyAuthenticationMiddleware.cs  // Validación de X-API-Key
```

### 2. UPSERT Eficiente con SQL Server MERGE

Usa **MERGE** de SQL Server para máximo rendimiento. Ejemplo para **Asociados**:

```sql
-- Stored Procedure: sp_UpsertAsociados
CREATE PROCEDURE sp_UpsertAsociados
    @Asociados dbo.AsociadosTableType READONLY  -- Table-Valued Parameter
AS
BEGIN
    SET NOCOUNT ON;
    
    MERGE genAsociados AS target
    USING @Asociados AS source
    ON target.Tercero = source.Tercero
    WHEN MATCHED THEN
        UPDATE SET 
            CodigoEntidad = source.CodigoEntidad,
            CodigoOficina = source.CodigoOficina,
            Documento = source.Documento,
            PrimerNombre = source.PrimerNombre,
            SegundoNombre = source.SegundoNombre,
            PrimerApellido = source.PrimerApellido,
            SegundoApellido = source.SegundoApellido,
            Antiguedad = source.Antiguedad,
            Email = source.Email,
            Celular = source.Celular,
            Estado = source.Estado,
            FechaMatricula = source.FechaMatricula
    WHEN NOT MATCHED THEN
        INSERT (CodigoEntidad, Tercero, CodigoOficina, Documento, PrimerNombre,
                SegundoNombre, PrimerApellido, SegundoApellido, Antiguedad,
                Email, Celular, Estado, FechaMatricula)
        VALUES (source.CodigoEntidad, source.Tercero, source.CodigoOficina,
                source.Documento, source.PrimerNombre, source.SegundoNombre,
                source.PrimerApellido, source.SegundoApellido, source.Antiguedad,
                source.Email, source.Celular, source.Estado, source.FechaMatricula);
    
    SELECT @@ROWCOUNT AS AffectedRows;
END
```

Crea SPs similares para **Productos** (`sp_UpsertProductos`), **Movimientos** (`sp_UpsertMovimientos`), y **Tasas** (`sp_UpsertTasas`).

### 3. Table-Valued Parameters (TVP)

Define un TVP para cada entidad:

```sql
-- Type: AsociadosTableType
CREATE TYPE dbo.AsociadosTableType AS TABLE
(
    CodigoEntidad smallint NOT NULL,
    Tercero bigint NOT NULL,
    CodigoOficina smallint NOT NULL,
    Documento varchar(15) NOT NULL,
    PrimerNombre varchar(20) NOT NULL,
    SegundoNombre varchar(20) NULL,
    PrimerApellido varchar(20) NOT NULL,
    SegundoApellido varchar(20) NULL,
    Antiguedad smallint NULL,
    Email varchar(100) NULL,
    Celular varchar(12) NULL,
    Estado smallint NULL,
    FechaMatricula smalldatetime NULL
);
```

Crea tipos similares: `ProductosTableType`, `MovimientosTableType`, `TasasTableType`.

### 4. Implementación en C# con Dapper

Ejemplo de Repository:

```csharp
public class AsociadoRepository : IAsociadoRepository
{
    private readonly string _connectionString;
    
    public AsociadoRepository(IConfiguration configuration)
    {
        _connectionString = configuration.GetConnectionString("DefaultConnection");
    }
    
    public async Task<int> UpsertAsociadosAsync(List<AsociadoDto> asociados)
    {
        using var connection = new SqlConnection(_connectionString);
        
        var dataTable = ConvertToDataTable(asociados);
        
        var parameters = new DynamicParameters();
        parameters.Add("@Asociados", dataTable.AsTableValuedParameter("dbo.AsociadosTableType"));
        
        var result = await connection.ExecuteScalarAsync<int>(
            "sp_UpsertAsociados",
            parameters,
            commandType: CommandType.StoredProcedure,
            commandTimeout: 120
        );
        
        return result;
    }
    
    private DataTable ConvertToDataTable(List<AsociadoDto> asociados)
    {
        var table = new DataTable();
        table.Columns.Add("CodigoEntidad", typeof(short));
        table.Columns.Add("Tercero", typeof(long));
        table.Columns.Add("CodigoOficina", typeof(short));
        table.Columns.Add("Documento", typeof(string));
        table.Columns.Add("PrimerNombre", typeof(string));
        table.Columns.Add("SegundoNombre", typeof(string));
        table.Columns.Add("PrimerApellido", typeof(string));
        table.Columns.Add("SegundoApellido", typeof(string));
        table.Columns.Add("Antiguedad", typeof(short));
        table.Columns.Add("Email", typeof(string));
        table.Columns.Add("Celular", typeof(string));
        table.Columns.Add("Estado", typeof(short));
        table.Columns.Add("FechaMatricula", typeof(DateTime));
        
        foreach (var a in asociados)
        {
            table.Rows.Add(
                a.CodigoEntidad,
                a.Tercero,
                a.CodigoOficina,
                a.Documento,
                a.PrimerNombre,
                a.SegundoNombre ?? (object)DBNull.Value,
                a.PrimerApellido,
                a.SegundoApellido ?? (object)DBNull.Value,
                a.Antiguedad.HasValue ? (object)a.Antiguedad.Value : DBNull.Value,
                a.Email ?? (object)DBNull.Value,
                a.Celular ?? (object)DBNull.Value,
                a.Estado.HasValue ? (object)a.Estado.Value : DBNull.Value,
                a.FechaMatricula.HasValue ? (object)a.FechaMatricula.Value : DBNull.Value
            );
        }
        
        return table;
    }
}
```

### 5. Controlador

```csharp
[ApiController]
[Route("api/integration")]
public class IntegrationController : ControllerBase
{
    private readonly IIntegrationService _integrationService;
    private readonly ILogger<IntegrationController> _logger;
    
    public IntegrationController(IIntegrationService integrationService, ILogger<IntegrationController> logger)
    {
        _integrationService = integrationService;
        _logger = logger;
    }
    
    [HttpPost("asociados")]
    public async Task<IActionResult> Asociados([FromBody] List<AsociadoDto> asociados)
    {
        try
        {
            if (asociados == null || !asociados.Any())
                return BadRequest(new { error = "La lista de asociados está vacía" });
            
            _logger.LogInformation($"Recibiendo {asociados.Count} asociados");
            
            var affectedRows = await _integrationService.ProcessAsociadosAsync(asociados);
            
            return Ok(new 
            { 
                success = true, 
                message = $"{affectedRows} asociados procesados exitosamente",
                count = asociados.Count,
                affectedRows = affectedRows
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error procesando asociados");
            return StatusCode(500, new { error = "Error interno procesando asociados", details = ex.Message });
        }
    }
    
    [HttpPost("productos")]
    public async Task<IActionResult> Productos([FromBody] List<ProductoDto> productos, [FromQuery] bool isFullLoad = false)
    {
        try
        {
            if (productos == null || !productos.Any())
                return BadRequest(new { error = "La lista de productos está vacía" });
            
            _logger.LogInformation($"Recibiendo {productos.Count} productos (FullLoad: {isFullLoad})");
            
            var affectedRows = await _integrationService.ProcessProductosAsync(productos, isFullLoad);
            
            return Ok(new 
            { 
                success = true, 
                message = $"{affectedRows} productos procesados exitosamente",
                count = productos.Count,
                affectedRows = affectedRows,
                isFullLoad = isFullLoad
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error procesando productos");
            return StatusCode(500, new { error = "Error interno procesando productos", details = ex.Message });
        }
    }
    
    [HttpPost("movimientos")]
    public async Task<IActionResult> Movimientos([FromBody] List<MovimientoDto> movimientos)
    {
        try
        {
            if (movimientos == null || !movimientos.Any())
                return BadRequest(new { error = "La lista de movimientos está vacía" });
            
            _logger.LogInformation($"Recibiendo {movimientos.Count} movimientos");
            
            var affectedRows = await _integrationService.ProcessMovimientosAsync(movimientos);
            
            return Ok(new 
            { 
                success = true, 
                message = $"{affectedRows} movimientos procesados exitosamente",
                count = movimientos.Count,
                affectedRows = affectedRows
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error procesando movimientos");
            return StatusCode(500, new { error = "Error interno procesando movimientos", details = ex.Message });
        }
    }
    
    [HttpPost("tasas")]
    public async Task<IActionResult> Tasas([FromBody] List<TasaDto> tasas)
    {
        try
        {
            if (tasas == null || !tasas.Any())
                return BadRequest(new { error = "La lista de tasas está vacía" });
            
            _logger.LogInformation($"Recibiendo {tasas.Count} tasas");
            
            var affectedRows = await _integrationService.ProcessTasasAsync(tasas);
            
            return Ok(new 
            { 
                success = true, 
                message = $"{affectedRows} tasas procesadas exitosamente",
                count = tasas.Count,
                affectedRows = affectedRows
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error procesando tasas");
            return StatusCode(500, new { error = "Error interno procesando tasas", details = ex.Message });
        }
    }
    
    [HttpPost("fecha-corte")]
    public async Task<IActionResult> FechaCorte([FromBody] FechaCorteDto fechaCorteDto)
    {
        try
        {
            if (fechaCorteDto?.FechaCorte == null)
                return BadRequest(new { error = "FechaCorte no puede ser nula" });
            
            _logger.LogInformation($"Actualizando fecha de corte: {fechaCorteDto.FechaCorte:yyyy-MM-dd}");
            
            await _integrationService.UpdateFechaCorteAsync(fechaCorteDto.FechaCorte.Value);
            
            return Ok(new 
            { 
                success = true, 
                message = "Fecha de corte actualizada exitosamente",
                fechaCorte = fechaCorteDto.FechaCorte.Value.ToString("yyyy-MM-dd")
            });
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, "Error actualizando fecha de corte");
            return StatusCode(500, new { error = "Error interno actualizando fecha de corte", details = ex.Message });
        }
    }
}
```

### 6. Servicio de Integración

```csharp
public class IntegrationService : IIntegrationService
{
    private readonly IAsociadoRepository _asociadoRepo;
    private readonly IProductoRepository _productoRepo;
    private readonly IMovimientoRepository _movimientoRepo;
    private readonly ITasaRepository _tasaRepo;
    private readonly IConfiguracionRepository _configRepo;
    private readonly ILogger<IntegrationService> _logger;
    
    public IntegrationService(
        IAsociadoRepository asociadoRepo,
        IProductoRepository productoRepo,
        IMovimientoRepository movimientoRepo,
        ITasaRepository tasaRepo,
        IConfiguracionRepository configRepo,
        ILogger<IntegrationService> logger)
    {
        _asociadoRepo = asociadoRepo;
        _productoRepo = productoRepo;
        _movimientoRepo = movimientoRepo;
        _tasaRepo = tasaRepo;
        _configRepo = configRepo;
        _logger = logger;
    }
    
    public async Task<int> ProcessAsociadosAsync(List<AsociadoDto> asociados)
    {
        var stopwatch = Stopwatch.StartNew();
        var affectedRows = await _asociadoRepo.UpsertAsociadosAsync(asociados);
        stopwatch.Stop();
        
        _logger.LogInformation($"Procesados {affectedRows} asociados en {stopwatch.ElapsedMilliseconds}ms");
        return affectedRows;
    }
    
    public async Task<int> ProcessProductosAsync(List<ProductoDto> productos, bool isFullLoad)
    {
        var stopwatch = Stopwatch.StartNew();
        
        // Si es FullLoad y es el primer batch del día, podría truncar
        // Pero según tu caso, parece que NO necesitas truncar
        
        var affectedRows = await _productoRepo.UpsertProductosAsync(productos);
        stopwatch.Stop();
        
        _logger.LogInformation($"Procesados {affectedRows} productos en {stopwatch.ElapsedMilliseconds}ms (FullLoad: {isFullLoad})");
        return affectedRows;
    }
    
    public async Task<int> ProcessMovimientosAsync(List<MovimientoDto> movimientos)
    {
        var stopwatch = Stopwatch.StartNew();
        var affectedRows = await _movimientoRepo.UpsertMovimientosAsync(movimientos);
        stopwatch.Stop();
        
        _logger.LogInformation($"Procesados {affectedRows} movimientos en {stopwatch.ElapsedMilliseconds}ms");
        return affectedRows;
    }
    
    public async Task<int> ProcessTasasAsync(List<TasaDto> tasas)
    {
        var stopwatch = Stopwatch.StartNew();
        var affectedRows = await _tasaRepo.UpsertTasasAsync(tasas);
        stopwatch.Stop();
        
        _logger.LogInformation($"Procesadas {affectedRows} tasas en {stopwatch.ElapsedMilliseconds}ms");
        return affectedRows;
    }
    
    public async Task UpdateFechaCorteAsync(DateTime fechaCorte)
    {
        await _configRepo.UpdateFechaCorteAsync(fechaCorte);
        _logger.LogInformation($"Fecha de corte actualizada: {fechaCorte:yyyy-MM-dd}");
    }
}
```

### 7. Middleware de API Key

```csharp
public class ApiKeyAuthenticationMiddleware
{
    private readonly RequestDelegate _next;
    private const string API_KEY_HEADER = "X-API-Key";
    private const string VALID_API_KEY = "LlaveAuthApiKey-!@#";
    
    public ApiKeyAuthenticationMiddleware(RequestDelegate next)
    {
        _next = next;
    }
    
    public async Task InvokeAsync(HttpContext context)
    {
        // Solo validar en rutas de integración
        if (context.Request.Path.StartsWithSegments("/api/integration"))
        {
            if (!context.Request.Headers.TryGetValue(API_KEY_HEADER, out var extractedApiKey))
            {
                context.Response.StatusCode = 401;
                await context.Response.WriteAsJsonAsync(new { error = "API Key no proporcionada" });
                return;
            }
            
            if (!VALID_API_KEY.Equals(extractedApiKey))
            {
                context.Response.StatusCode = 401;
                await context.Response.WriteAsJsonAsync(new { error = "API Key inválida" });
                return;
            }
        }
        
        await _next(context);
    }
}

// En Program.cs:
app.UseMiddleware<ApiKeyAuthenticationMiddleware>();
```

---

## 📊 CONSIDERACIONES DE PERFORMANCE

1. **Batch Size**: El Worker envía hasta 500 registros por batch. Optimiza para este tamaño.

2. **Timeouts**: Configura timeouts generosos (120 segundos) para los SP.

3. **Índices**: Las tablas ya deben tener índices en las claves primarias. Verifica que existan.

4. **Transacciones**: Los SP MERGE ya son transaccionales. No envuelvas en transacciones adicionales.

5. **Logging**: Registra:
   - Cantidad de registros recibidos
   - Tiempo de procesamiento
   - Errores con stack trace completo

---

## ✅ RESPUESTAS ESPERADAS

### Éxito (200 OK)
```json
{
  "success": true,
  "message": "500 asociados procesados exitosamente",
  "count": 500,
  "affectedRows": 500
}
```

### Error de validación (400 Bad Request)
```json
{
  "error": "La lista de asociados está vacía"
}
```

### Error de autenticación (401 Unauthorized)
```json
{
  "error": "API Key inválida"
}
```

### Error interno (500 Internal Server Error)
```json
{
  "error": "Error interno procesando asociados",
  "details": "Cannot insert duplicate key..."
}
```

---

## 🎯 EJEMPLO DE PAYLOAD ENVIADO POR EL WORKER

### POST /api/integration/asociados
```json
[
  {
    "codigoEntidad": 1,
    "tercero": 123456,
    "codigoOficina": 10,
    "documento": "1234567890",
    "primerNombre": "Juan",
    "segundoNombre": "Carlos",
    "primerApellido": "Pérez",
    "segundoApellido": "García",
    "antiguedad": 5,
    "email": "juan.perez@example.com",
    "celular": "3001234567",
    "estado": 1,
    "fechaMatricula": "2024-01-15T00:00:00"
  },
  {
    "codigoEntidad": 1,
    "tercero": 123457,
    "codigoOficina": 10,
    "documento": "9876543210",
    "primerNombre": "María",
    "segundoNombre": null,
    "primerApellido": "López",
    "segundoApellido": "Martínez",
    "antiguedad": 3,
    "email": null,
    "celular": "3009876543",
    "estado": 1,
    "fechaMatricula": "2023-06-20T00:00:00"
  }
]
```

---

## 📚 DEPENDENCIAS NUGET

```xml
<PackageReference Include="Dapper" Version="2.1.35" />
<PackageReference Include="Microsoft.Data.SqlClient" Version="5.1.5" />
<PackageReference Include="Serilog.AspNetCore" Version="8.0.0" />
```

---

## ✅ CHECKLIST DE IMPLEMENTACIÓN

- [ ] Agrega un controlador nuevo en FedinApp.API
- [ ] Agregar DTOs (5 clases)
- [ ] Crear Table-Valued Types en SQL Server (4 tipos)
- [ ] Crear Stored Procedures con MERGE (4 SPs)
- [ ] Implementar Repositories (5 clases)
- [ ] Implementar IntegrationService
- [ ] Crear IntegrationController con 5 endpoints
- [ ] Implementar ApiKeyAuthenticationMiddleware
- [ ] Configurar Serilog para logging
- [ ] Probar con Postman/curl cada endpoint
- [ ] Validar UPSERT (INSERT y UPDATE funcionan correctamente)
- [ ] Verificar performance con lotes de 500 o más, esto debe ser muy optimo recuerda registros

---

## 🚀 RESULTADO ESPERADO

Una API robusta que:
- ✅ Recibe datos del Worker Service en lotes de 500
- ✅ Valida autenticación con API Key
- ✅ Procesa UPSERT eficiente con MERGE de SQL Server
- ✅ Retorna respuestas claras (200/400/401/500)
- ✅ Registra logs detallados
- ✅ Maneja errores 
- ✅ Soporta carga completa e incremental

---

**¡Listo para implementar la API de migración!** 🚀
