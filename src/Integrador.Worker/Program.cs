using Integrador.Infrastructure.Repositories;
using Integrador.Worker;
using Integrador.Worker.Services;
using Serilog;
using System.Reflection;

// Usar una ruta accesible para el servicio de Windows
var baseDirectory = AppDomain.CurrentDomain.BaseDirectory;
var logsDirectory = Path.Combine(baseDirectory, "Logs");

// Intentar crear la carpeta de logs con manejo de errores
try
{
    if (!Directory.Exists(logsDirectory))
    {
        Directory.CreateDirectory(logsDirectory);
    }
}
catch
{
    // Si falla, usar ProgramData que es accesible para servicios
    baseDirectory = Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), "IntegradorOptimo");
    logsDirectory = Path.Combine(baseDirectory, "Logs");
    Directory.CreateDirectory(logsDirectory);
}

var logsPath = Path.Combine(logsDirectory, "startup-.txt");

// Configurar Serilog ANTES de crear el builder para capturar errores tempranos
Log.Logger = new LoggerConfiguration()
    .MinimumLevel.Debug()
    .WriteTo.Console()
    .WriteTo.File(logsPath, 
        rollingInterval: RollingInterval.Day, 
        shared: true,
        flushToDiskInterval: TimeSpan.FromSeconds(1))
    .CreateLogger();

Log.Information("?? Iniciando desde: {BaseDirectory}", baseDirectory);
Log.Information("?? Logs en: {LogsPath}", logsPath);

try
{
    var builder = Host.CreateApplicationBuilder(args);

    // Reconfigurar Serilog con rutas absolutas y flush inmediato
    var logFilePath = Path.Combine(logsDirectory, "log-.txt");
    
    Log.Logger = new LoggerConfiguration()
        .MinimumLevel.Debug()
        .WriteTo.Console()
        .WriteTo.File(
            logFilePath, 
            rollingInterval: RollingInterval.Day,
            retainedFileCountLimit: 30,
            shared: true,
            flushToDiskInterval: TimeSpan.FromSeconds(1),
            outputTemplate: "{Timestamp:yyyy-MM-dd HH:mm:ss.fff zzz} [{Level:u3}] {Message:lj}{NewLine}{Exception}")
        .CreateLogger();

    Log.Information("?? Archivo de logs principal: {LogFilePath}", logFilePath);
    Log.Information("?? Sistema operativo: {OS}", Environment.OSVersion);
    Log.Information("?? Usuario: {User}", Environment.UserName);
    
    builder.Services.AddSerilog();

    // Configurar como Windows Service (funciona también en modo consola)
    builder.Services.AddWindowsService(options =>
    {
        options.ServiceName = "IntegradorOptimo";
    });

    var erpConnectionString = builder.Configuration.GetConnectionString("ErpDatabase");
    var destinationConnectionString = builder.Configuration.GetConnectionString("DestinationDatabase");

    if (string.IsNullOrEmpty(erpConnectionString))
    {
        Log.Fatal("? ErpDatabase connection string not found in configuration");
        Console.WriteLine("? ERROR: ErpDatabase connection string not found in configuration");
        Console.WriteLine("\nPresiona cualquier tecla para salir...");
        Console.ReadKey();
        throw new InvalidOperationException("ErpDatabase connection string not found");
    }

    if (string.IsNullOrEmpty(destinationConnectionString))
    {
        Log.Fatal("? DestinationDatabase connection string not found in configuration");
        Console.WriteLine("? ERROR: DestinationDatabase connection string not found in configuration");
        Console.WriteLine("\nPresiona cualquier tecla para salir...");
        Console.ReadKey();
        throw new InvalidOperationException("DestinationDatabase connection string not found");
    }

    builder.Services.AddSingleton<IIntegrationSettingsRepository>(sp => 
        new IntegrationSettingsRepository(destinationConnectionString));

    builder.Services.AddSingleton<IErpRepository>(sp => 
        new ErpRepository(erpConnectionString));

    builder.Services.AddHttpClient<IApiClientService, ApiClientService>()
        .AddPolicyHandler(PollyPolicies.GetRetryPolicy())
        .AddPolicyHandler(PollyPolicies.GetCircuitBreakerPolicy());

    builder.Services.AddHostedService<IntegrationWorker>();

    var host = builder.Build();

    Log.Information("?? IntegradorOptimo Worker Service iniciado");
    await host.RunAsync();
}
catch (Exception ex)
{
    var errorMessage = $@"
??? FATAL ERROR - Application failed to start ???

Exception Type: {ex.GetType().Name}
Exception Message: {ex.Message}
{(ex.InnerException != null ? $"Inner Exception: {ex.InnerException.Message}" : "")}

Stack Trace:
{ex.StackTrace}
";

    Console.ForegroundColor = ConsoleColor.Red;
    Console.WriteLine(errorMessage);
    Console.ResetColor();

    Log.Fatal(ex, "??? FATAL ERROR - Application failed to start");
    Log.Fatal("Exception Type: {ExceptionType}", ex.GetType().Name);
    Log.Fatal("Exception Message: {Message}", ex.Message);
    if (ex.InnerException != null)
    {
        Log.Fatal("Inner Exception: {InnerMessage}", ex.InnerException.Message);
    }
    
    // Mantener la consola abierta para ver el error
    Console.WriteLine("\n========================================");
    Console.WriteLine("Presiona cualquier tecla para salir...");
    Console.WriteLine("========================================");
    Console.ReadKey();
    
    Environment.Exit(1);
}
finally
{
    Log.Information("?? Cerrando IntegradorOptimo Worker Service");
    Log.CloseAndFlush();
}

static string GetServerFromConnectionString(string connectionString)
{
    var parts = connectionString.Split(';');
    var dataSource = parts.FirstOrDefault(p => p.Trim().StartsWith("Data Source=", StringComparison.OrdinalIgnoreCase));
    return dataSource?.Split('=')[1]?.Trim() ?? "Unknown";
}
