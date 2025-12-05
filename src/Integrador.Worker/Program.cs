using Integrador.Infrastructure.Repositories;
using Integrador.Worker;
using Integrador.Worker.Services;
using Serilog;

var builder = Host.CreateApplicationBuilder(args);

Log.Logger = new LoggerConfiguration()
    .ReadFrom.Configuration(builder.Configuration)
    .CreateLogger();

builder.Services.AddSerilog();

builder.Services.AddWindowsService(options =>
{
    options.ServiceName = "IntegradorOptimo";
});

var erpConnectionString = builder.Configuration.GetConnectionString("ErpDatabase")
    ?? throw new InvalidOperationException("ErpDatabase connection string not found");

var destinationConnectionString = builder.Configuration.GetConnectionString("DestinationDatabase")
    ?? throw new InvalidOperationException("DestinationDatabase connection string not found");

builder.Services.AddSingleton<IIntegrationSettingsRepository>(sp => 
    new IntegrationSettingsRepository(destinationConnectionString));

builder.Services.AddSingleton<IErpRepository>(sp => 
    new ErpRepository(erpConnectionString));

builder.Services.AddHttpClient<IApiClientService, ApiClientService>()
    .AddPolicyHandler(PollyPolicies.GetRetryPolicy())
    .AddPolicyHandler(PollyPolicies.GetCircuitBreakerPolicy());

builder.Services.AddHostedService<IntegrationWorker>();

var host = builder.Build();

try
{
    Log.Information("?? Iniciando IntegradorOptimo Worker Service");
    await host.RunAsync();
}
catch (Exception ex)
{
    Log.Fatal(ex, "? Error fatal en IntegradorOptimo");
    throw;
}
finally
{
    Log.CloseAndFlush();
}
