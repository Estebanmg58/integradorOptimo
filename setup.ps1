# ============================================
# Script de Generación Automática
# integradorOptimo - Solución Completa
# ============================================

Write-Host "🚀 Iniciando creación de integradorOptimo..." -ForegroundColor Cyan

# Crear estructura de carpetas
$folders = @(
    "src\Integrador. Worker\Services",
    "src\Integrador.Core\DTOs",
    "src\Integrador.Core\Models",
    "src\Integrador.Infrastructure\Repositories",
    "database",
    "docs",
    "postman",
    ". github\workflows"
)

foreach ($folder in $folders) {
    New-Item -ItemType Directory -Force -Path $folder | Out-Null
    Write-Host "✅ Creado: $folder" -ForegroundColor Green
}

Write-Host "`n📄 Creando archivos de solución..." -ForegroundColor Yellow

# ============================================
# 1.  SOLUTION FILE
# ============================================
@"
Microsoft Visual Studio Solution File, Format Version 12.00
# Visual Studio Version 17
VisualStudioVersion = 17.8.0.0
MinimumVisualStudioVersion = 10.0.40219.1
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "Integrador.Worker", "src\Integrador.Worker\Integrador.Worker.csproj", "{A1111111-1111-1111-1111-111111111111}"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "Integrador.Core", "src\Integrador.Core\Integrador.Core.csproj", "{B2222222-2222-2222-2222-222222222222}"
EndProject
Project("{FAE04EC0-301F-11D3-BF4B-00C04F79EFBC}") = "Integrador.Infrastructure", "src\Integrador.Infrastructure\Integrador.Infrastructure.csproj", "{C3333333-3333-3333-3333-333333333333}"
EndProject
Global
	GlobalSection(SolutionConfigurationPlatforms) = preSolution
		Debug|Any CPU = Debug|Any CPU
		Release|Any CPU = Release|Any CPU
	EndGlobalSection
	GlobalSection(ProjectConfigurationPlatforms) = postSolution
		{A1111111-1111-1111-1111-111111111111}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{A1111111-1111-1111-1111-111111111111}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{A1111111-1111-1111-1111-111111111111}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{A1111111-1111-1111-1111-111111111111}.Release|Any CPU.Build.0 = Release|Any CPU
		{B2222222-2222-2222-2222-222222222222}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{B2222222-2222-2222-2222-222222222222}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{B2222222-2222-2222-2222-222222222222}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{B2222222-2222-2222-2222-222222222222}.Release|Any CPU.Build.0 = Release|Any CPU
		{C3333333-3333-3333-3333-333333333333}.Debug|Any CPU.ActiveCfg = Debug|Any CPU
		{C3333333-3333-3333-3333-333333333333}.Debug|Any CPU.Build.0 = Debug|Any CPU
		{C3333333-3333-3333-3333-333333333333}.Release|Any CPU.ActiveCfg = Release|Any CPU
		{C3333333-3333-3333-3333-333333333333}.Release|Any CPU.Build.0 = Release|Any CPU
	EndGlobalSection
EndGlobal
"@ | Out-File -FilePath "Integrador.sln" -Encoding UTF8

# ============================================
# 2. INTEGRADOR.CORE
# ============================================

# Integrador.Core.csproj
@"
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>
</Project>
"@ | Out-File -FilePath "src\Integrador.Core\Integrador.Core.csproj" -Encoding UTF8

# DTOs/AsociadoDto.cs
@"
namespace Integrador.Core.DTOs;

public class AsociadoDto
{
    public string NumeroDocumento { get; set; } = string.Empty;
    public string Nombres { get; set; } = string.Empty;
    public string Apellidos { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string Celular { get; set; } = string.Empty;
    public DateTime FechaAfiliacion { get; set; }
    public string Estado { get; set; } = string.Empty;
}
"@ | Out-File -FilePath "src\Integrador.Core\DTOs\AsociadoDto.cs" -Encoding UTF8

# DTOs/ProductoDto.cs
@"
namespace Integrador.Core.DTOs;

public class ProductoDto
{
    public string NumeroDocumento { get; set; } = string.Empty;
    public string CodigoProducto { get; set; } = string.Empty;
    public string NombreProducto { get; set; } = string.Empty;
    public decimal Saldo { get; set; }
    public DateTime FechaApertura { get; set; }
    public string Estado { get; set; } = string.Empty;
}
"@ | Out-File -FilePath "src\Integrador.Core\DTOs\ProductoDto.cs" -Encoding UTF8

# DTOs/MovimientoDto.cs
@"
namespace Integrador.Core.DTOs;

public class MovimientoDto
{
    public string NumeroDocumento { get; set; } = string.Empty;
    public string CodigoProducto { get; set; } = string.Empty;
    public DateTime FechaMovimiento { get; set; }
    public string TipoMovimiento { get; set; } = string.Empty;
    public decimal Valor { get; set; }
    public string Descripcion { get; set; } = string.Empty;
}
"@ | Out-File -FilePath "src\Integrador.Core\DTOs\MovimientoDto.cs" -Encoding UTF8

# DTOs/TasaDto.cs
@"
namespace Integrador.Core.DTOs;

public class TasaDto
{
    public string CodigoTasa { get; set; } = string.Empty;
    public string NombreTasa { get; set; } = string.Empty;
    public decimal ValorTasa { get; set; }
    public DateTime FechaVigencia { get; set; }
}
"@ | Out-File -FilePath "src\Integrador.Core\DTOs\TasaDto.cs" -Encoding UTF8

# DTOs/FechaCorteDto.cs
@"
namespace Integrador.Core.DTOs;

public class FechaCorteDto
{
    public DateTime FechaCorte { get; set; }
}
"@ | Out-File -FilePath "src\Integrador.Core\DTOs\FechaCorteDto.cs" -Encoding UTF8

# Models/IntegrationSettings.cs
@"
namespace Integrador.Core.Models;

public class IntegrationSettings
{
    public string ScheduleCron { get; set; } = ""0 2 * * *""; // 2 AM diario
    public int BatchSize { get; set; } = 500;
    public int DailyTruncateHour { get; set; } = 2;
    public bool EnableAsociados { get; set; } = true;
    public bool EnableProductos { get; set; } = true;
    public bool EnableMovimientos { get; set; } = true;
    public bool EnableTasas { get; set; } = true;
    public bool EnableFechaCorte { get; set; } = true;
}
"@ | Out-File -FilePath "src\Integrador.Core\Models\IntegrationSettings.cs" -Encoding UTF8

# ============================================
# 3.  INTEGRADOR.INFRASTRUCTURE
# ============================================

# Integrador. Infrastructure.csproj
@"
<Project Sdk="Microsoft. NET.Sdk">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include=""Dapper"" Version=""2.1.35"" />
    <PackageReference Include=""Microsoft.Data.SqlClient"" Version=""5.1.5"" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include="". .\Integrador.Core\Integrador.Core.csproj"" />
  </ItemGroup>
</Project>
"@ | Out-File -FilePath "src\Integrador.Infrastructure\Integrador.Infrastructure.csproj" -Encoding UTF8

# Repositories/IIntegrationSettingsRepository.cs
@"
using Integrador.Core.Models;

namespace Integrador.Infrastructure. Repositories;

public interface IIntegrationSettingsRepository
{
    Task<IntegrationSettings> GetSettingsAsync();
    Task UpdateSettingAsync(string key, string value);
}
"@ | Out-File -FilePath "src\Integrador.Infrastructure\Repositories\IIntegrationSettingsRepository.cs" -Encoding UTF8

# Repositories/IntegrationSettingsRepository.cs
@"
using Dapper;
using Integrador.Core.Models;
using Microsoft.Data.SqlClient;

namespace Integrador.Infrastructure.Repositories;

public class IntegrationSettingsRepository : IIntegrationSettingsRepository
{
    private readonly string _connectionString;

    public IntegrationSettingsRepository(string connectionString)
    {
        _connectionString = connectionString;
    }

    public async Task<IntegrationSettings> GetSettingsAsync()
    {
        using var connection = new SqlConnection(_connectionString);
        var settings = await connection.QueryAsync<(string Key, string Value)>(
            ""SELECT SettingKey, SettingValue FROM IntegrationSettings""
        );

        var settingsDict = settings.ToDictionary(s => s.Key, s => s.Value);
        
        return new IntegrationSettings
        {
            ScheduleCron = settingsDict.GetValueOrDefault(""ScheduleCron"", ""0 2 * * *""),
            BatchSize = int.Parse(settingsDict.GetValueOrDefault(""BatchSize"", ""500"")),
            DailyTruncateHour = int.Parse(settingsDict.GetValueOrDefault(""DailyTruncateHour"", ""2"")),
            EnableAsociados = bool.Parse(settingsDict.GetValueOrDefault(""EnableAsociados"", ""true"")),
            EnableProductos = bool.Parse(settingsDict.GetValueOrDefault(""EnableProductos"", ""true"")),
            EnableMovimientos = bool. Parse(settingsDict.GetValueOrDefault(""EnableMovimientos"", ""true"")),
            EnableTasas = bool.Parse(settingsDict.GetValueOrDefault(""EnableTasas"", ""true"")),
            EnableFechaCorte = bool.Parse(settingsDict.GetValueOrDefault(""EnableFechaCorte"", ""true""))
        };
    }

    public async Task UpdateSettingAsync(string key, string value)
    {
        using var connection = new SqlConnection(_connectionString);
        await connection.ExecuteAsync(
            ""UPDATE IntegrationSettings SET SettingValue = @Value, LastModified = GETDATE() WHERE SettingKey = @Key"",
            new { Key = key, Value = value }
        );
    }
}
"@ | Out-File -FilePath "src\Integrador.Infrastructure\Repositories\IntegrationSettingsRepository.cs" -Encoding UTF8

# Repositories/IErpRepository.cs
@"
using Integrador.Core.DTOs;

namespace Integrador.Infrastructure. Repositories;

public interface IErpRepository
{
    Task<List<AsociadoDto>> GetAsociadosAsync(CancellationToken ct);
    Task<List<ProductoDto>> GetProductosAsync(CancellationToken ct);
    Task<List<MovimientoDto>> GetMovimientosAsync(CancellationToken ct);
    Task<List<TasaDto>> GetTasasAsync(CancellationToken ct);
    Task<DateTime> GetFechaCorteAsync(CancellationToken ct);
}
"@ | Out-File -FilePath "src\Integrador.Infrastructure\Repositories\IErpRepository.cs" -Encoding UTF8

# Repositories/ErpRepository.cs
@"
using Dapper;
using Integrador. Core.DTOs;
using Microsoft.Data.SqlClient;

namespace Integrador.Infrastructure.Repositories;

public class ErpRepository : IErpRepository
{
    private readonly string _connectionString;

    public ErpRepository(string connectionString)
    {
        _connectionString = connectionString;
    }

    public async Task<List<AsociadoDto>> GetAsociadosAsync(CancellationToken ct)
    {
        using var connection = new SqlConnection(_connectionString);
        var result = await connection.QueryAsync<AsociadoDto>(
            ""ERP_SPConsultaDta"",
            new { TipoConsulta = 1 }, // 1 = Asociados
            commandType: System.Data.CommandType.StoredProcedure,
            commandTimeout: 120
        );
        return result.ToList();
    }

    public async Task<List<ProductoDto>> GetProductosAsync(CancellationToken ct)
    {
        using var connection = new SqlConnection(_connectionString);
        var result = await connection.QueryAsync<ProductoDto>(
            ""ERP_SPConsultaDta"",
            new { TipoConsulta = 2 }, // 2 = Productos
            commandType: System. Data.CommandType.StoredProcedure,
            commandTimeout: 120
        );
        return result.ToList();
    }

    public async Task<List<MovimientoDto>> GetMovimientosAsync(CancellationToken ct)
    {
        using var connection = new SqlConnection(_connectionString);
        var result = await connection.QueryAsync<MovimientoDto>(
            ""ERP_SPConsultaDta"",
            new { TipoConsulta = 3 }, // 3 = Movimientos
            commandType: System.Data.CommandType.StoredProcedure,
            commandTimeout: 300
        );
        return result. ToList();
    }

    public async Task<List<TasaDto>> GetTasasAsync(CancellationToken ct)
    {
        using var connection = new SqlConnection(_connectionString);
        var result = await connection. QueryAsync<TasaDto>(
            ""ERP_SPConsultaDta"",
            new { TipoConsulta = 4 }, // 4 = Tasas
            commandType: System.Data.CommandType. StoredProcedure,
            commandTimeout: 60
        );
        return result. ToList();
    }

    public async Task<DateTime> GetFechaCorteAsync(CancellationToken ct)
    {
        using var connection = new SqlConnection(_connectionString);
        var result = await connection.QuerySingleAsync<DateTime>(
            ""ERP_SPConsultaDta"",
            new { TipoConsulta = 5 }, // 5 = FechaCorte
            commandType: System.Data. CommandType.StoredProcedure,
            commandTimeout: 30
        );
        return result;
    }
}
"@ | Out-File -FilePath "src\Integrador.Infrastructure\Repositories\ErpRepository.cs" -Encoding UTF8

# ============================================
# 4.  INTEGRADOR.WORKER
# ============================================

# Integrador.Worker.csproj
@"
<Project Sdk="Microsoft.NET.Sdk. Worker">
  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
    <UserSecretsId>dotnet-Integrador. Worker-20250104</UserSecretsId>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include=""Microsoft.Extensions.Hosting"" Version=""8.0.0"" />
    <PackageReference Include=""Microsoft.Extensions.Hosting.WindowsServices"" Version=""8.0. 0"" />
    <PackageReference Include=""Serilog.Extensions.Hosting"" Version=""8.0. 0"" />
    <PackageReference Include=""Serilog.Sinks. File"" Version=""5.0.0"" />
    <PackageReference Include=""Polly"" Version=""8.2.0"" />
    <PackageReference Include=""Polly.Extensions.Http"" Version=""3.0.0"" />
    <PackageReference Include=""NCrontab"" Version=""3.3.3"" />
  </ItemGroup>

  <ItemGroup>
    <ProjectReference Include=""..\Integrador.Core\Integrador.Core.csproj"" />
    <ProjectReference Include=""..\Integrador.Infrastructure\Integrador.Infrastructure.csproj"" />
  </ItemGroup>
</Project>
"@ | Out-File -FilePath "src\Integrador.Worker\Integrador.Worker.csproj" -Encoding UTF8

# Program.cs
@"
using Integrador.Infrastructure.Repositories;
using Integrador.Worker;
using Integrador.Worker.Services;
using Serilog;

// Configurar Serilog
Log.Logger = new LoggerConfiguration()
    . WriteTo.File(""C:\\Logs\\IntegradorOptimo\\log-. txt"", rollingInterval: RollingInterval. Day, retainedFileCountLimit: 30)
    . WriteTo.Console()
    . CreateLogger();

try
{
    Log.Information(""Iniciando Integrador Optimo Worker"");

    var builder = Host.CreateApplicationBuilder(args);

    // Configurar como Windows Service
    builder.Services.AddWindowsService(options =>
    {
        options.ServiceName = ""IntegradorOptimo"";
    });

    // Configurar Serilog
    builder.Services.AddSerilog();

    // Obtener connection strings
    var erpConnString = builder.Configuration.GetConnectionString(""ErpDatabase"") 
        ?? throw new InvalidOperationException(""ErpDatabase connection string not found"");
    
    var destConnString = builder.Configuration.GetConnectionString(""DestinationDatabase"") 
        ??  throw new InvalidOperationException(""DestinationDatabase connection string not found"");

    // Registrar repositorios
    builder. Services.AddSingleton<IIntegrationSettingsRepository>(sp => 
        new IntegrationSettingsRepository(destConnString));
    
    builder.Services.AddSingleton<IErpRepository>(sp => 
        new ErpRepository(erpConnString));

    // Registrar servicios
    builder.Services.AddScoped<IApiClientService, ApiClientService>();

    // Configurar HttpClient con Polly
    builder.Services.AddHttpClient<IApiClientService, ApiClientService>()
        .AddPolicyHandler(PollyPolicies.GetRetryPolicy())
        .AddPolicyHandler(PollyPolicies.GetCircuitBreakerPolicy());

    // Registrar Worker
    builder.Services.AddHostedService<IntegrationWorker>();

    var host = builder.Build();
    host.Run();
}
catch (Exception ex)
{
    Log.Fatal(ex, ""Application start-up failed"");
}
finally
{
    Log.CloseAndFlush();
}
"@ | Out-File -FilePath "src\Integrador.Worker\Program.cs" -Encoding UTF8

# IntegrationWorker.cs
@"
using Integrador.Core.DTOs;
using Integrador.Infrastructure.Repositories;
using Integrador.Worker.Services;
using NCrontab;
using System. Diagnostics;

namespace Integrador.Worker;

public class IntegrationWorker : BackgroundService
{
    private readonly ILogger<IntegrationWorker> _logger;
    private readonly IServiceProvider _serviceProvider;

    public IntegrationWorker(ILogger<IntegrationWorker> logger, IServiceProvider serviceProvider)
    {
        _logger = logger;
        _serviceProvider = serviceProvider;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation(""IntegrationWorker iniciado a las: {time}"", DateTimeOffset.Now);

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = _serviceProvider.CreateScope();
                var settingsRepo = scope.ServiceProvider.GetRequiredService<IIntegrationSettingsRepository>();
                var settings = await settingsRepo.GetSettingsAsync();

                // Calcular próxima ejecución usando cron
                var schedule = CrontabSchedule.Parse(settings.ScheduleCron);
                var nextRun = schedule.GetNextOccurrence(DateTime.Now);
                var delay = nextRun - DateTime. Now;

                _logger.LogInformation(""Próxima ejecución programada: {NextRun} (en {Minutes} minutos)"", 
                    nextRun, delay.TotalMinutes);

                if (delay > TimeSpan.Zero)
                {
                    await Task.Delay(delay, stoppingToken);
                }

                await RunIntegrationAsync(stoppingToken);
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, ""Error en ciclo principal del worker"");
                await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken); // Esperar 5 min antes de reintentar
            }
        }
    }

    private async Task RunIntegrationAsync(CancellationToken ct)
    {
        var totalSw = Stopwatch.StartNew();
        _logger.LogInformation(""========================================"");
        _logger.LogInformation(""🚀 INICIANDO SINCRONIZACIÓN COMPLETA"");
        _logger.LogInformation(""========================================"");

        try
        {
            using var scope = _serviceProvider.CreateScope();
            var settingsRepo = scope.ServiceProvider.GetRequiredService<IIntegrationSettingsRepository>();
            var erpRepo = scope.ServiceProvider. GetRequiredService<IErpRepository>();
            var apiClient = scope.ServiceProvider.GetRequiredService<IApiClientService>();
            
            var settings = await settingsRepo.GetSettingsAsync();

            // 1.  Asociados
            if (settings.EnableAsociados)
                await SyncAsociadosAsync(erpRepo, apiClient, settings. BatchSize, ct);

            // 2.  Productos
            if (settings. EnableProductos)
            {
                bool isFullLoad = DateTime.Now.Hour == settings.DailyTruncateHour;
                await SyncProductosAsync(erpRepo, apiClient, settings.BatchSize, isFullLoad, ct);
            }

            // 3. Movimientos
            if (settings.EnableMovimientos)
                await SyncMovimientosAsync(erpRepo, apiClient, settings.BatchSize, ct);

            // 4. Tasas
            if (settings.EnableTasas)
                await SyncTasasAsync(erpRepo, apiClient, ct);

            // 5. FechaCorte
            if (settings.EnableFechaCorte)
                await SyncFechaCorteAsync(erpRepo, apiClient, ct);

            totalSw.Stop();
            _logger.LogInformation(""========================================"");
            _logger. LogInformation(""✅ SINCRONIZACIÓN COMPLETADA EN {Seconds}s"", totalSw. Elapsed.TotalSeconds);
            _logger.LogInformation(""========================================"");
        }
        catch (Exception ex)
        {
            _logger.LogError(ex, ""❌ Error en sincronización"");
            throw;
        }
    }

    private async Task SyncAsociadosAsync(IErpRepository erpRepo, IApiClientService apiClient, int batchSize, CancellationToken ct)
    {
        _logger.LogInformation(""📊 Sincronizando Asociados..."");
        var sw = Stopwatch.StartNew();
        
        var asociados = await erpRepo.GetAsociadosAsync(ct);
        _logger.LogInformation(""   Total asociados obtenidos: {Count}"", asociados.Count);

        var batches = asociados.Chunk(batchSize). ToList();
        int batchNo = 0;

        foreach (var batch in batches)
        {
            batchNo++;
            var batchSw = Stopwatch.StartNew();
            
            await apiClient.SendAsociadosAsync(batch. ToList(), ct);
            
            _logger.LogInformation(""   ✅ Batch {BatchNo}/{Total}: {Count} registros en {Ms}ms"", 
                batchNo, batches.Count, batch.Count(), batchSw.ElapsedMilliseconds);
        }

        _logger.LogInformation(""   ✅ Asociados completados en {Seconds}s"", sw. Elapsed.TotalSeconds);
    }

    private async Task SyncProductosAsync(IErpRepository erpRepo, IApiClientService apiClient, int batchSize, bool isFullLoad, CancellationToken ct)
    {
        _logger.LogInformation(""📦 Sincronizando Productos (FullLoad: {IsFullLoad})..."", isFullLoad);
        var sw = Stopwatch.StartNew();
        
        var productos = await erpRepo.GetProductosAsync(ct);
        _logger. LogInformation(""   Total productos obtenidos: {Count}"", productos.Count);

        var batches = productos.Chunk(batchSize).ToList();
        int batchNo = 0;

        foreach (var batch in batches)
        {
            batchNo++;
            var batchSw = Stopwatch.StartNew();
            
            // Solo el primer batch hace TRUNCATE si es fullLoad
            bool truncateThisBatch = isFullLoad && batchNo == 1;
            await apiClient.SendProductosAsync(batch.ToList(), truncateThisBatch, ct);
            
            _logger.LogInformation(""   ✅ Batch {BatchNo}/{Total}: {Count} registros en {Ms}ms"", 
                batchNo, batches.Count, batch.Count(), batchSw. ElapsedMilliseconds);
        }

        _logger.LogInformation(""   ✅ Productos completados en {Seconds}s"", sw. Elapsed.TotalSeconds);
    }

    private async Task SyncMovimientosAsync(IErpRepository erpRepo, IApiClientService apiClient, int batchSize, CancellationToken ct)
    {
        _logger.LogInformation(""💰 Sincronizando Movimientos..."");
        var sw = Stopwatch.StartNew();
        
        var movimientos = await erpRepo.GetMovimientosAsync(ct);
        _logger.LogInformation(""   Total movimientos obtenidos: {Count}"", movimientos.Count);

        var batches = movimientos.Chunk(batchSize). ToList();
        int batchNo = 0;

        foreach (var batch in batches)
        {
            batchNo++;
            var batchSw = Stopwatch.StartNew();
            
            await apiClient.SendMovimientosAsync(batch. ToList(), ct);
            
            _logger.LogInformation(""   ✅ Batch {BatchNo}/{Total}: {Count} registros en {Ms}ms"", 
                batchNo, batches.Count, batch. Count(), batchSw.ElapsedMilliseconds);
        }

        _logger.LogInformation(""   ✅ Movimientos completados en {Seconds}s"", sw. Elapsed.TotalSeconds);
    }

    private async Task SyncTasasAsync(IErpRepository erpRepo, IApiClientService apiClient, CancellationToken ct)
    {
        _logger.LogInformation(""📈 Sincronizando Tasas..."");
        var sw = Stopwatch.StartNew();
        
        var tasas = await erpRepo.GetTasasAsync(ct);
        await apiClient.SendTasasAsync(tasas, ct);
        
        _logger.LogInformation(""   ✅ Tasas completadas ({Count} registros) en {Ms}ms"", 
            tasas.Count, sw.ElapsedMilliseconds);
    }

    private async Task SyncFechaCorteAsync(IErpRepository erpRepo, IApiClientService apiClient, CancellationToken ct)
    {
        _logger.LogInformation(""📅 Sincronizando Fecha Corte..."");
        var sw = Stopwatch.StartNew();
        
        var fechaCorte = await erpRepo.GetFechaCorteAsync(ct);
        await apiClient.SendFechaCorteAsync(new FechaCorteDto { FechaCorte = fechaCorte }, ct);
        
        _logger.LogInformation(""   ✅ Fecha Corte actualizada: {FechaCorte} en {Ms}ms"", 
            fechaCorte, sw.ElapsedMilliseconds);
    }
}
"@ | Out-File -FilePath "src\Integrador.Worker\IntegrationWorker.cs" -Encoding UTF8

# Services/IApiClientService.cs
@"
using Integrador.Core.DTOs;

namespace Integrador.Worker. Services;

public interface IApiClientService
{
    Task SendAsociadosAsync(List<AsociadoDto> asociados, CancellationToken ct);
    Task SendProductosAsync(List<ProductoDto> productos, bool isFullLoad, CancellationToken ct);
    Task SendMovimientosAsync(List<MovimientoDto> movimientos, CancellationToken ct);
    Task SendTasasAsync(List<TasaDto> tasas, CancellationToken ct);
    Task SendFechaCorteAsync(FechaCorteDto fechaCorte, CancellationToken ct);
}
"@ | Out-File -FilePath "src\Integrador.Worker\Services\IApiClientService.cs" -Encoding UTF8

# Services/ApiClientService.cs
@"
using Integrador.Core.DTOs;
using System.Net.Http. Headers;
using System.Text;
using System.Text.Json;

namespace Integrador.Worker.Services;

public class ApiClientService : IApiClientService
{
    private readonly HttpClient _httpClient;
    private readonly ILogger<ApiClientService> _logger;
    private readonly string _baseUrl;
    private readonly string _jwtToken;

    public ApiClientService(HttpClient httpClient, IConfiguration configuration, ILogger<ApiClientService> logger)
    {
        _httpClient = httpClient;
        _logger = logger;
        _baseUrl = configuration[""ApiSettings:BaseUrl""] ?? throw new InvalidOperationException(""ApiSettings:BaseUrl not configured"");
        _jwtToken = configuration[""ApiSettings:JwtToken""] ?? throw new InvalidOperationException(""ApiSettings:JwtToken not configured"");
        
        _httpClient.BaseAddress = new Uri(_baseUrl);
        _httpClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue(""Bearer"", _jwtToken);
        _httpClient. Timeout = TimeSpan.FromMinutes(5);
    }

    public async Task SendAsociadosAsync(List<AsociadoDto> asociados, CancellationToken ct)
    {
        await PostAsync(""api/integration/asociados"", asociados, ct);
    }

    public async Task SendProductosAsync(List<ProductoDto> productos, bool isFullLoad, CancellationToken ct)
    {
        await PostAsync($""api/integration/productos? isFullLoad={isFullLoad}"", productos, ct);
    }

    public async Task SendMovimientosAsync(List<MovimientoDto> movimientos, CancellationToken ct)
    {
        await PostAsync(""api/integration/movimientos"", movimientos, ct);
    }

    public async Task SendTasasAsync(List<TasaDto> tasas, CancellationToken ct)
    {
        await PostAsync(""api/integration/tasas"", tasas, ct);
    }

    public async Task SendFechaCorteAsync(FechaCorteDto fechaCorte, CancellationToken ct)
    {
        await PostAsync(""api/integration/fecha-corte"", fechaCorte, ct);
    }

    private async Task PostAsync<T>(string endpoint, T data, CancellationToken ct)
    {
        var json = JsonSerializer.Serialize(data, new JsonSerializerOptions { PropertyNamingPolicy = JsonNamingPolicy.CamelCase });
        var content = new StringContent(json, Encoding.UTF8, ""application/json"");

        var response = await _httpClient.PostAsync(endpoint, content, ct);
        
        if (!response. IsSuccessStatusCode)
        {
            var error = await response.Content.ReadAsStringAsync(ct);
            _logger.LogError(""Error al enviar datos a {Endpoint}: {StatusCode} - {Error}"", endpoint, response.StatusCode, error);
            response.EnsureSuccessStatusCode();
        }
    }
}
"@ | Out-File -FilePath "src\Integrador.Worker\Services\ApiClientService.cs" -Encoding UTF8

# Services/PollyPolicies.cs
@"
using Polly;
using Polly. Extensions.Http;

namespace Integrador.Worker.Services;

public static class PollyPolicies
{
    public static IAsyncPolicy<HttpResponseMessage> GetRetryPolicy()
    {
        return HttpPolicyExtensions
            .HandleTransientHttpError()
            .WaitAndRetryAsync(
                retryCount: 3,
                sleepDurationProvider: retryAttempt => TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)),
                onRetry: (outcome, timespan, retryCount, context) =>
                {
                    Console.WriteLine($""Reintento {retryCount} después de {timespan.TotalSeconds}s"");
                }
            );
    }

    public static IAsyncPolicy<HttpResponseMessage> GetCircuitBreakerPolicy()
    {
        return HttpPolicyExtensions
            .HandleTransientHttpError()
            .CircuitBreakerAsync(
                handledEventsAllowedBeforeBreaking: 5,
                durationOfBreak: TimeSpan.FromSeconds(30),
                onBreak: (outcome, duration) =>
                {
                    Console.WriteLine($""Circuit breaker abierto por {duration.TotalSeconds}s"");
                },
                onReset: () =>
                {
                    Console.WriteLine(""Circuit breaker cerrado"");
                }
            );
    }
}
"@ | Out-File -FilePath "src\Integrador.Worker\Services\PollyPolicies.cs" -Encoding UTF8

# appsettings.json
@"
{
  ""ConnectionStrings"": {
    ""ErpDatabase"": ""Server=SERVIDOR_ERP;Database=ERP_DB;User Id=USUARIO;Password=PLACEHOLDER_PASSWORD;TrustServerCertificate=true;"",
    ""DestinationDatabase"": ""Server=SERVIDOR_DESTINO;Database=FodnoSuma;User Id=USUARIO;Password=PLACEHOLDER_PASSWORD;TrustServerCertificate=true;""
  },
  ""ApiSettings"": {
    ""BaseUrl"": ""https://api.fodnosuma.com"",
    ""JwtToken"": ""PLACEHOLDER_JWT_TOKEN""
  },
  ""Logging"": {
    ""LogLevel"": {
      ""Default"": ""Information"",
      ""Microsoft. Hosting.Lifetime"": ""Information""
    }
  }
}
"@ | Out-File -FilePath "src\Integrador.Worker\appsettings. json" -Encoding UTF8

Write-Host "`n✅ Proyectos . NET creados!" -ForegroundColor Green

# ============================================
# 5. DATABASE SCRIPTS
# ============================================

Write-Host "`n📊 Creando scripts SQL..." -ForegroundColor Yellow

# 00_IntegrationSettings.sql
@"
-- ============================================
-- IntegradorOptimo - Tabla de Configuración
-- ============================================

-- Crear tabla si no existe
IF NOT EXISTS (SELECT * FROM sys. objects WHERE object_id = OBJECT_ID(N'[dbo].[IntegrationSettings]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[IntegrationSettings] (
        [Id] INT PRIMARY KEY IDENTITY(1,1),
        [SettingKey] NVARCHAR(100) NOT NULL UNIQUE,
        [SettingValue] NVARCHAR(500) NOT NULL,
        [LastModified] DATETIME2 DEFAULT GETDATE(),
        [Description] NVARCHAR(500) NULL
    );
    
    PRINT 'Tabla IntegrationSettings creada';
END
ELSE
BEGIN
    PRINT 'Tabla IntegrationSettings ya existe';
END
GO

-- Insertar configuración inicial (idempotente)
MERGE [dbo].[IntegrationSettings] AS target
USING (VALUES
    ('ScheduleCron', '0 2 * * *', 'Programación cron (2 AM diario por defecto)'),
    ('BatchSize', '500', 'Tamaño de lote para procesamiento por batches'),
    ('DailyTruncateHour', '2', 'Hora del día para TRUNCATE de productos (0-23)'),
    ('EnableAsociados', 'true', 'Habilitar sincronización de Asociados'),
    ('EnableProductos', 'true', 'Habilitar sincronización de Productos'),
    ('EnableMovimientos', 'true', 'Habilitar sincronización de Movimientos'),
    ('EnableTasas', 'true', 'Habilitar sincronización de Tasas'),
    ('EnableFechaCorte', 'true', 'Habilitar sincronización de Fecha Corte')
) AS source ([SettingKey], [SettingValue], [Description])
ON target.[SettingKey] = source.[SettingKey]
WHEN NOT MATCHED THEN
    INSERT ([SettingKey], [SettingValue], [Description])
    VALUES (source.[SettingKey], source.[SettingValue], source.[Description]);

PRINT 'Configuración inicial insertada/actualizada';
GO

-- Consultar configuración actual
SELECT * FROM [dbo].[IntegrationSettings];
GO
"@ | Out-File -FilePath "database\00_IntegrationSettings.sql" -Encoding UTF8

# 01_TableTypes.sql
@"
-- ============================================
-- IntegradorOptimo - Table-Valued Parameters
-- ============================================

-- AsociadosTableType
IF EXISTS (SELECT * FROM sys.types WHERE is_table_type = 1 AND name = 'AsociadosTableType')
    DROP TYPE [dbo].[AsociadosTableType];
GO

CREATE TYPE [dbo].[AsociadosTableType] AS TABLE (
    [NumeroDocumento] NVARCHAR(20) NOT NULL,
    [Nombres] NVARCHAR(100) NOT NULL,
    [Apellidos] NVARCHAR(100) NOT NULL,
    [Email] NVARCHAR(100) NULL,
    [Celular] NVARCHAR(20) NULL,
    [FechaAfiliacion] DATETIME2 NULL,
    [Estado] NVARCHAR(20) NOT NULL
);
GO

PRINT 'Tipo AsociadosTableType creado';
GO

-- ProductosTableType
IF EXISTS (SELECT * FROM sys. types WHERE is_table_type = 1 AND name = 'ProductosTableType')
    DROP TYPE [dbo].[ProductosTableType];
GO

CREATE TYPE [dbo].[ProductosTableType] AS TABLE (
    [NumeroDocumento] NVARCHAR(20) NOT NULL,
    [CodigoProducto] NVARCHAR(50) NOT NULL,
    [NombreProducto] NVARCHAR(200) NOT NULL,
    [Saldo] DECIMAL(18,2) NOT NULL,
    [FechaApertura] DATETIME2 NULL,
    [Estado] NVARCHAR(20) NOT NULL
);
GO

PRINT 'Tipo ProductosTableType creado';
GO

-- MovimientosTableType
IF EXISTS (SELECT * FROM sys.types WHERE is_table_type = 1 AND name = 'MovimientosTableType')
    DROP TYPE [dbo].[MovimientosTableType];
GO

CREATE TYPE [dbo].[MovimientosTableType] AS TABLE (
    [NumeroDocumento] NVARCHAR(20) NOT NULL,
    [CodigoProducto] NVARCHAR(50) NOT NULL,
    [FechaMovimiento] DATETIME2 NOT NULL,
    [TipoMovimiento] NVARCHAR(50) NOT NULL,
    [Valor] DECIMAL(18,2) NOT NULL,
    [Descripcion] NVARCHAR(300) NULL
);
GO

PRINT 'Tipo MovimientosTableType creado';
GO

-- TasasTableType
IF EXISTS (SELECT * FROM sys. types WHERE is_table_type = 1 AND name = 'TasasTableType')
    DROP TYPE [dbo].[TasasTableType];
GO

CREATE TYPE [dbo].[TasasTableType] AS TABLE (
    [CodigoTasa] NVARCHAR(50) NOT NULL,
    [NombreTasa] NVARCHAR(200) NOT NULL,
    [ValorTasa] DECIMAL(10,6) NOT NULL,
    [FechaVigencia] DATETIME2 NOT NULL
);
GO

PRINT 'Tipo TasasTableType creado';
GO
"@ | Out-File -FilePath "database\01_TableTypes.sql" -Encoding UTF8

# 02_StoredProcedures.sql
@"
-- ============================================
-- IntegradorOptimo - Stored Procedures
-- SIN CURSORES - Usando MERGE y TRUNCATE+INSERT
-- ============================================

-- sp_UpsertAsociados
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_UpsertAsociados]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_UpsertAsociados];
GO

CREATE PROCEDURE [dbo].[sp_UpsertAsociados]
    @Asociados [dbo].[AsociadosTableType] READONLY
AS
BEGIN
    SET NOCOUNT ON;
    
    MERGE [dbo].[Asociados] AS target
    USING @Asociados AS source
    ON target.[NumeroDocumento] = source.[NumeroDocumento]
    WHEN MATCHED THEN
        UPDATE SET
            [Nombres] = source.[Nombres],
            [Apellidos] = source.[Apellidos],
            [Email] = source.[Email],
            [Celular] = source.[Celular],
            [FechaAfiliacion] = source.[FechaAfiliacion],
            [Estado] = source.[Estado],
            [FechaModificacion] = GETDATE()
    WHEN NOT MATCHED THEN
        INSERT ([NumeroDocumento], [Nombres], [Apellidos], [Email], [Celular], [FechaAfiliacion], [Estado], [FechaCreacion])
        VALUES (source.[NumeroDocumento], source.[Nombres], source.[Apellidos], source.[Email], 
                source.[Celular], source.[FechaAfiliacion], source.[Estado], GETDATE());
    
    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

PRINT 'sp_UpsertAsociados creado';
GO

-- sp_UpsertProductos
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_UpsertProductos]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_UpsertProductos];
GO

CREATE PROCEDURE [dbo].[sp_UpsertProductos]
    @Productos [dbo].[ProductosTableType] READONLY,
    @IsFullLoad BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    
    IF @IsFullLoad = 1
    BEGIN
        -- TRUNCATE completo y carga desde cero
        TRUNCATE TABLE [dbo].[Productos];
        
        INSERT INTO [dbo].[Productos] ([NumeroDocumento], [CodigoProducto], [NombreProducto], [Saldo], [FechaApertura], [Estado], [FechaCreacion])
        SELECT [NumeroDocumento], [CodigoProducto], [NombreProducto], [Saldo], [FechaApertura], [Estado], GETDATE()
        FROM @Productos;
        
        SELECT @@ROWCOUNT AS RowsAffected;
    END
    ELSE
    BEGIN
        -- Actualización incremental con MERGE
        MERGE [dbo].[Productos] AS target
        USING @Productos AS source
        ON target.[NumeroDocumento] = source.[NumeroDocumento] AND target.[CodigoProducto] = source.[CodigoProducto]
        WHEN MATCHED THEN
            UPDATE SET
                [NombreProducto] = source.[NombreProducto],
                [Saldo] = source.[Saldo],
                [FechaApertura] = source.[FechaApertura],
                [Estado] = source.[Estado],
                [FechaModificacion] = GETDATE()
        WHEN NOT MATCHED THEN
            INSERT ([NumeroDocumento], [CodigoProducto], [NombreProducto], [Saldo], [FechaApertura], [Estado], [FechaCreacion])
            VALUES (source.[NumeroDocumento], source.[CodigoProducto], source.[NombreProducto], 
                    source.[Saldo], source.[FechaApertura], source.[Estado], GETDATE());
        
        SELECT @@ROWCOUNT AS RowsAffected;
    END;
END;
GO

PRINT 'sp_UpsertProductos creado';
GO

-- sp_UpsertMovimientos
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_UpsertMovimientos]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_UpsertMovimientos];
GO

CREATE PROCEDURE [dbo].[sp_UpsertMovimientos]
    @Movimientos [dbo].[MovimientosTableType] READONLY
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Los movimientos típicamente son insert-only
    -- Usamos MERGE para evitar duplicados
    MERGE [dbo].[Movimientos] AS target
    USING @Movimientos AS source
    ON target.[NumeroDocumento] = source.[NumeroDocumento] 
       AND target.[CodigoProducto] = source.[CodigoProducto]
       AND target.[FechaMovimiento] = source.[FechaMovimiento]
       AND target.[TipoMovimiento] = source.[TipoMovimiento]
    WHEN NOT MATCHED THEN
        INSERT ([NumeroDocumento], [CodigoProducto], [FechaMovimiento], [TipoMovimiento], [Valor], [Descripcion], [FechaCreacion])
        VALUES (source.[NumeroDocumento], source.[CodigoProducto], source.[FechaMovimiento], 
                source.[TipoMovimiento], source.[Valor], source.[Descripcion], GETDATE());
    
    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

PRINT 'sp_UpsertMovimientos creado';
GO

-- sp_ReplaceTasas
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ReplaceTasas]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_ReplaceTasas];
GO

CREATE PROCEDURE [dbo].[sp_ReplaceTasas]
    @Tasas [dbo].[TasasTableType] READONLY
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Tasas siempre TRUNCATE + INSERT (tabla pequeña ~100 registros)
    TRUNCATE TABLE [dbo].[Tasas];
    
    INSERT INTO [dbo].[Tasas] ([CodigoTasa], [NombreTasa], [ValorTasa], [FechaVigencia], [FechaCreacion])
    SELECT [CodigoTasa], [NombreTasa], [ValorTasa], [FechaVigencia], GETDATE()
    FROM @Tasas;
    
    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

PRINT 'sp_ReplaceTasas creado';
GO

-- sp_UpdateFechaCorte
IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_UpdateFechaCorte]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_UpdateFechaCorte];
GO

CREATE PROCEDURE [dbo].[sp_UpdateFechaCorte]
    @FechaCorte DATETIME2
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Asumiendo que existe tabla Configuracion con Id=1 para FechaCorte
    -- Ajustar según estructura real
    UPDATE [dbo].[Configuracion]
    SET [FechaCorte] = @FechaCorte,
        [FechaModificacion] = GETDATE()
    WHERE [Id] = 1;
    
    IF @@ROWCOUNT = 0
    BEGIN
        INSERT INTO [dbo].[Configuracion] ([FechaCorte], [FechaCreacion])
        VALUES (@FechaCorte, GETDATE());
    END
    
    SELECT @@ROWCOUNT AS RowsAffected;
END;
GO

PRINT 'sp_UpdateFechaCorte creado';
GO
"@ | Out-File -FilePath "database\02_StoredProcedures.sql" -Encoding UTF8

# 03_Indexes.sql
@"
-- ============================================
-- IntegradorOptimo - Índices Sugeridos
-- ============================================

-- Asociados
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Asociados_NumeroDocumento' AND object_id = OBJECT_ID('dbo. Asociados'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX IX_Asociados_NumeroDocumento
    ON [dbo].[Asociados] ([NumeroDocumento]);
    
    PRINT 'Índice IX_Asociados_NumeroDocumento creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys. indexes WHERE name = 'IX_Asociados_Estado' AND object_id = OBJECT_ID('dbo.Asociados'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Asociados_Estado
    ON [dbo].[Asociados] ([Estado])
    INCLUDE ([NumeroDocumento], [Nombres], [Apellidos]);
    
    PRINT 'Índice IX_Asociados_Estado creado';
END
GO

-- Productos
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Productos_NumeroDocumento_CodigoProducto' AND object_id = OBJECT_ID('dbo.Productos'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX IX_Productos_NumeroDocumento_CodigoProducto
    ON [dbo].[Productos] ([NumeroDocumento], [CodigoProducto]);
    
    PRINT 'Índice IX_Productos_NumeroDocumento_CodigoProducto creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Productos_Estado' AND object_id = OBJECT_ID('dbo.Productos'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Productos_Estado
    ON [dbo].[Productos] ([Estado])
    INCLUDE ([NumeroDocumento], [CodigoProducto], [Saldo]);
    
    PRINT 'Índice IX_Productos_Estado creado';
END
GO

-- Movimientos
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Movimientos_NumeroDocumento' AND object_id = OBJECT_ID('dbo.Movimientos'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Movimientos_NumeroDocumento
    ON [dbo].[Movimientos] ([NumeroDocumento])
    INCLUDE ([FechaMovimiento], [TipoMovimiento], [Valor]);
    
    PRINT 'Índice IX_Movimientos_NumeroDocumento creado';
END
GO

IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Movimientos_FechaMovimiento' AND object_id = OBJECT_ID('dbo.Movimientos'))
BEGIN
    CREATE NONCLUSTERED INDEX IX_Movimientos_FechaMovimiento
    ON [dbo].[Movimientos] ([FechaMovimiento] DESC);
    
    PRINT 'Índice IX_Movimientos_FechaMovimiento creado';
END
GO

-- Tasas
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE name = 'IX_Tasas_CodigoTasa' AND object_id = OBJECT_ID('dbo.Tasas'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX IX_Tasas_CodigoTasa
    ON [dbo].[Tasas] ([CodigoTasa]);
    
    PRINT 'Índice IX_Tasas_CodigoTasa creado';
END
GO

PRINT 'Todos los índices han sido creados/verificados';
GO
"@ | Out-File -FilePath "database\03_Indexes.sql" -Encoding UTF8

Write-Host "✅ Scripts SQL creados!" -ForegroundColor Green

# ============================================
# 6. DOCUMENTATION
# ============================================

Write-Host "`n📚 Creando documentación..." -ForegroundColor Yellow

# README.md
@"
# 🚀 Integrador Óptimo

**Solución empresarial de sincronización de datos ERP → FodnoSuma**

Sistema optimizado para cooperativa financiera que sincroniza hasta 100K registros de movimientos con mínima sobrecarga de base de datos.

---

## 📊 Arquitectura

\`\`\`
┌─────────────┐       ┌──────────────────┐       ┌─────────────┐
│  ERP (SQL)  │ ────▶ │ Worker (Windows) │ ────▶ │ FodnoSuma   │
│  Origen     │       │ Background Svc   │ JSON  │ API + SQL   │
└─────────────┘       └──────────────────┘       └─────────────┘
                             │
                             ▼
                      C:\Logs\IntegradorOptimo\
\`\`\`

---

## ⚡ Características

- ✅ **Sin cursores**: SPs optimizados con MERGE y TRUNCATE+INSERT
- ✅ **TVP (Table-Valued Parameters)**: Procesamiento por lotes eficiente
- ✅ **Reintentos automáticos**: Polly con circuit breaker
- ✅ **Logs locales**: Archivos en disco, sin sobrecarga en BD
- ✅ **Configurable**: Schedule, batch size y entidades habilitadas
- ✅ **Windows Service**: Ejecuta automáticamente en segundo plano

---

## 🛠️ Tecnologías

- . NET 8.0
- SQL Server 2019+
- Dapper (TVP support)
- Serilog (file logging)
- Polly (resilience)
- NCrontab (scheduling)

---

## 📦 Volúmenes Soportados

| Entidad      | Registros  | Batch Size | Tiempo Estimado |
|--------------|------------|------------|-----------------|
| Asociados    | ~9,000     | 500        | 5-8s            |
| Productos    | ~14,000    | 500        | 8-12s           |
| Movimientos  | ~100,000   | 500        | 15-25s          |
| Tasas        | ~100       | N/A        | <1s             |
| FechaCorte   | 1          | N/A        | <1s             |

**Total: 20-40 segundos** para sincronización completa (hardware: SSD, 4-8 vCPU, 16-32GB RAM)

---

## 🚀 Instalación

### 1. Prerequisitos

- Windows Server 2019+ o Windows 10/11
- .NET 8 Runtime (o SDK para desarrollo)
- SQL Server 2019+
- Permisos de administrador para instalar servicios

### 2.  Compilar el proyecto

\`\`\`bash
dotnet build -c Release
dotnet publish src/Integrador.Worker -c Release -r win-x64 --self-contained true -o C:\IntegradorOptimo
\`\`\`

### 3.  Ejecutar scripts SQL

Conectarse a SQL Server destino (FodnoSuma) y ejecutar en orden:

\`\`\`sql
-- En la base de datos de destino
USE FodnoSuma;
GO

-- 1. Configuración
:r database\00_IntegrationSettings.sql

-- 2. Tipos de tabla
:r database\01_TableTypes.sql

-- 3.  Stored procedures
:r database\02_StoredProcedures.sql

-- 4. Índices (opcional pero recomendado)
:r database\03_Indexes.sql
\`\`\`

### 4. Configurar variables de entorno

**Opción A: Variables de sistema (recomendado para producción)**

\`\`\`powershell
[Environment]::SetEnvironmentVariable(""ConnectionStrings__ErpDatabase"", ""Server=SERVIDOR_ERP;Database=ERP;User Id=user;Password=pass;TrustServerCertificate=true;"", ""Machine"")
[Environment]::SetEnvironmentVariable(""ConnectionStrings__DestinationDatabase"", ""Server=SERVIDOR_DESTINO;Database=FodnoSuma;User Id=user;Password=pass;TrustServerCertificate=true;"", ""Machine"")
[Environment]::SetEnvironmentVariable(""ApiSettings__BaseUrl"", ""https://api.fodnosuma.com"", ""Machine"")
[Environment]::SetEnvironmentVariable(""ApiSettings__JwtToken"", ""eyJhbGc..."", ""Machine"")
\`\`\`

**Opción B: Editar appsettings.json (desarrollo)**

Editar `C:\IntegradorOptimo\appsettings.json` con valores reales. 

### 5. Instalar como servicio de Windows

\`\`\`powershell
# Crear servicio
sc. exe create IntegradorOptimo binPath= ""C:\IntegradorOptimo\Integrador.Worker.exe"" start= auto

# Iniciar servicio
sc.exe start IntegradorOptimo

# Verificar estado
sc.exe query IntegradorOptimo
\`\`\`

### 6. Verificar logs

Los logs se generan en:

\`\`\`
C:\Logs\IntegradorOptimo\log-20250104. txt
\`\`\`

---

## ⚙️ Configuración

### Cambiar schedule (cron)

**Opción 1: Base de datos**

\`\`\`sql
UPDATE IntegrationSettings
SET SettingValue = '0 3 * * *'  -- 3 AM diario
WHERE SettingKey = 'ScheduleCron';
\`\`\`

**Opción 2: Variable de entorno (override)**

\`\`\`powershell
[Environment]::SetEnvironmentVariable(""IntegrationSettings__ScheduleCron"", ""0 3 * * *"", ""Machine"")
sc.exe stop IntegradorOptimo
sc. 