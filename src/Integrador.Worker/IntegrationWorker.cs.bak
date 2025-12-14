using System.Diagnostics;
using Integrador.Core.DTOs;
using Integrador.Infrastructure.Repositories;
using Integrador.Worker.Services;
using NCrontab;

namespace Integrador.Worker;

public class IntegrationWorker : BackgroundService
{
    private readonly ILogger<IntegrationWorker> _logger;
    private readonly IServiceProvider _serviceProvider;
    private const int LARGE_DATASET_THRESHOLD = 100000;
    private const int GC_BATCH_INTERVAL = 50;

    public IntegrationWorker(ILogger<IntegrationWorker> logger, IServiceProvider serviceProvider)
    {
        _logger = logger;
        _serviceProvider = serviceProvider;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        _logger.LogInformation("?? Integrador Óptimo iniciado - Servicio de Windows activo");

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var scope = _serviceProvider.CreateScope();
                var settingsRepo = scope.ServiceProvider.GetRequiredService<IIntegrationSettingsRepository>();
                var settings = await settingsRepo.GetSettingsAsync();

                var schedule = CrontabSchedule.Parse(settings.ScheduleCron);
                var nextRun = schedule.GetNextOccurrence(DateTime.Now);

                _logger.LogInformation($"? Próxima ejecución programada: {nextRun:yyyy-MM-dd HH:mm:ss}");

                var delay = nextRun - DateTime.Now;
                if (delay.TotalMilliseconds > 0)
                {
                    await Task.Delay(delay, stoppingToken);
                }

                if (!stoppingToken.IsCancellationRequested)
                {
                    await RunIntegrationAsync(stoppingToken);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "? Error en el ciclo principal del Worker");
                await Task.Delay(TimeSpan.FromMinutes(5), stoppingToken);
            }
        }

        _logger.LogInformation("?? Integrador Óptimo detenido");
    }

    private async Task RunIntegrationAsync(CancellationToken ct)
    {
        var totalStopwatch = Stopwatch.StartNew();

        try
        {
            _logger.LogInformation("========================================");
            _logger.LogInformation("?? INICIANDO SINCRONIZACIÓN COMPLETA");
            _logger.LogInformation("========================================");

            using var scope = _serviceProvider.CreateScope();
            var settingsRepo = scope.ServiceProvider.GetRequiredService<IIntegrationSettingsRepository>();
            var erpRepo = scope.ServiceProvider.GetRequiredService<IErpRepository>();
            var apiClient = scope.ServiceProvider.GetRequiredService<IApiClientService>();

            var settings = await settingsRepo.GetSettingsAsync();

            if (settings.EnableAsociados)
            {
                await SyncAsociadosAsync(erpRepo, apiClient, settings.BatchSize, ct);
            }

            if (settings.EnableProductos)
            {
                var isFullLoad = DateTime.Now.Hour == settings.DailyTruncateHour;
                await SyncProductosAsync(erpRepo, apiClient, settings.BatchSize, isFullLoad, ct);
            }

            if (settings.EnableMovimientos)
            {
                await SyncMovimientosAsync(erpRepo, apiClient, settings.BatchSize, ct);
            }

            if (settings.EnableTasas)
            {
                await SyncTasasAsync(erpRepo, apiClient, settings.BatchSize, ct);
            }

            if (settings.EnableFechaCorte)
            {
                await SyncFechaCorteAsync(erpRepo, apiClient, ct);
            }

            totalStopwatch.Stop();
            _logger.LogInformation("========================================");
            _logger.LogInformation($"? SINCRONIZACIÓN COMPLETADA EN {totalStopwatch.Elapsed.TotalSeconds:F1}s");
            _logger.LogInformation("========================================");
        }
        catch (Exception ex)
        {
            totalStopwatch.Stop();
            _logger.LogError(ex, $"? ERROR EN SINCRONIZACIÓN después de {totalStopwatch.Elapsed.TotalSeconds:F1}s");
        }
    }

    private async Task SyncAsociadosAsync(IErpRepository erpRepo, IApiClientService apiClient, int batchSize, CancellationToken ct)
    {
        var stopwatch = Stopwatch.StartNew();
        _logger.LogInformation("?? Sincronizando Asociados...");

        try
        {
            var asociados = await erpRepo.GetAsociadosAsync(ct);
            var totalRecords = asociados.Count;
            _logger.LogInformation($"   Total asociados obtenidos: {totalRecords:N0}");

            if (totalRecords > LARGE_DATASET_THRESHOLD)
            {
                _logger.LogWarning($"   ??  Dataset grande detectado ({totalRecords:N0} registros). Activando optimizaciones de memoria.");
            }

            var batches = asociados.Chunk(batchSize);
            var totalBatches = (int)Math.Ceiling((double)totalRecords / batchSize);
            var batchNumber = 0;

            foreach (var batch in batches)
            {
                ct.ThrowIfCancellationRequested();

                var batchStopwatch = Stopwatch.StartNew();
                var batchList = batch.ToList();

                await apiClient.SendAsociadosAsync(batchList, ct);

                batchStopwatch.Stop();
                batchNumber++;

                _logger.LogInformation($"   ? Batch {batchNumber}/{totalBatches}: {batchList.Count} registros en {batchStopwatch.ElapsedMilliseconds}ms");

                if (totalRecords > LARGE_DATASET_THRESHOLD && batchNumber % GC_BATCH_INTERVAL == 0)
                {
                    GC.Collect(1, GCCollectionMode.Optimized);
                    _logger.LogDebug($"   ?? Memoria liberada después del batch {batchNumber}");
                }

                batchList.Clear();
            }

            if (totalRecords > LARGE_DATASET_THRESHOLD)
            {
                asociados.Clear();
                GC.Collect(2, GCCollectionMode.Forced);
                GC.WaitForPendingFinalizers();
                _logger.LogDebug("   ?? Limpieza final de memoria completada");
            }

            stopwatch.Stop();
            _logger.LogInformation($"   ? Asociados completados en {stopwatch.Elapsed.TotalSeconds:F1}s");
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            _logger.LogError(ex, $"   ? Error sincronizando Asociados después de {stopwatch.Elapsed.TotalSeconds:F1}s");
            throw;
        }
    }

    private async Task SyncProductosAsync(IErpRepository erpRepo, IApiClientService apiClient, int batchSize, bool isFullLoad, CancellationToken ct)
    {
        var stopwatch = Stopwatch.StartNew();
        _logger.LogInformation($"📦 Sincronizando Productos...");

        try
        {
            var productos = await erpRepo.GetProductosAsync(ct);
            var totalRecords = productos.Count;
            _logger.LogInformation($"   Total productos obtenidos: {totalRecords:N0}");

            // 🔥 MODO PRUEBA: Enviar TODOS los productos de una vez
            _logger.LogWarning($"Enviando TODOS los {totalRecords:N0} productos en un solo lote...");

            var sendStopwatch = Stopwatch.StartNew();
            await apiClient.SendProductosAsync(productos, isFullLoad, ct);
            sendStopwatch.Stop();

            _logger.LogInformation($"   ✅ {totalRecords:N0} productos enviados en {sendStopwatch.Elapsed.TotalSeconds:F2} segundos ({sendStopwatch.ElapsedMilliseconds:N0}ms)");
            _logger.LogInformation($"   📊 Performance: {(totalRecords / sendStopwatch.Elapsed.TotalSeconds):F0} registros/segundo");

            // Limpieza de memoria
            productos.Clear();
            GC.Collect(2, GCCollectionMode.Forced);
            GC.WaitForPendingFinalizers();

            stopwatch.Stop();
            _logger.LogInformation($"   ✅ Productos completados en {stopwatch.Elapsed.TotalSeconds:F1}s");
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            _logger.LogError(ex, $"   ❌ Error sincronizando Productos después de {stopwatch.Elapsed.TotalSeconds:F1}s");
            throw;
        }
    }

    private async Task SyncMovimientosAsync(IErpRepository erpRepo, IApiClientService apiClient, int batchSize, CancellationToken ct)
    {
        var stopwatch = Stopwatch.StartNew();
        _logger.LogInformation("?? Sincronizando Movimientos...");

        try
        {
            var movimientos = await erpRepo.GetMovimientosAsync(ct);
            var totalRecords = movimientos.Count;
            _logger.LogInformation($"   Total movimientos obtenidos: {totalRecords:N0}");

            if (totalRecords > LARGE_DATASET_THRESHOLD)
            {
                _logger.LogWarning($"   ??  Dataset grande detectado ({totalRecords:N0} registros). Activando optimizaciones de memoria.");
            }

            var batches = movimientos.Chunk(batchSize);
            var totalBatches = (int)Math.Ceiling((double)totalRecords / batchSize);
            var batchNumber = 0;

            foreach (var batch in batches)
            {
                ct.ThrowIfCancellationRequested();

                var batchStopwatch = Stopwatch.StartNew();
                var batchList = batch.ToList();

                await apiClient.SendMovimientosAsync(batchList, ct);

                batchStopwatch.Stop();
                batchNumber++;

                _logger.LogInformation($"   ? Batch {batchNumber}/{totalBatches}: {batchList.Count} registros en {batchStopwatch.ElapsedMilliseconds}ms");

                if (totalRecords > LARGE_DATASET_THRESHOLD && batchNumber % GC_BATCH_INTERVAL == 0)
                {
                    GC.Collect(1, GCCollectionMode.Optimized);
                    GC.WaitForPendingFinalizers();
                    _logger.LogDebug($"   ?? Memoria liberada después del batch {batchNumber}");
                }

                batchList.Clear();
            }

            if (totalRecords > LARGE_DATASET_THRESHOLD)
            {
                movimientos.Clear();
                GC.Collect(2, GCCollectionMode.Forced);
                GC.WaitForPendingFinalizers();
                _logger.LogDebug("   ?? Limpieza final de memoria completada para Movimientos");
            }

            stopwatch.Stop();
            _logger.LogInformation($"   ? Movimientos completados en {stopwatch.Elapsed.TotalSeconds:F1}s");
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            _logger.LogError(ex, $"   ? Error sincronizando Movimientos después de {stopwatch.Elapsed.TotalSeconds:F1}s");
            throw;
        }
    }

    private async Task SyncTasasAsync(IErpRepository erpRepo, IApiClientService apiClient, int batchSize, CancellationToken ct)
    {
        var stopwatch = Stopwatch.StartNew();
        _logger.LogInformation("?? Sincronizando Tasas...");

        try
        {
            var tasas = await erpRepo.GetTasasAsync(ct);

            await apiClient.SendTasasAsync(tasas, ct);

            stopwatch.Stop();
            _logger.LogInformation($"   ? Tasas completadas ({tasas.Count} registros) en {stopwatch.ElapsedMilliseconds}ms");
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            _logger.LogError(ex, $"   ? Error sincronizando Tasas después de {stopwatch.Elapsed.TotalSeconds:F1}s");
            throw;
        }
    }

    private async Task SyncFechaCorteAsync(IErpRepository erpRepo, IApiClientService apiClient, CancellationToken ct)
    {
        var stopwatch = Stopwatch.StartNew();
        _logger.LogInformation("?? Sincronizando Fecha Corte...");

        try
        {
            var fechaCorte = await erpRepo.GetFechaCorteAsync(ct);
            var dto = new FechaCorteDto { FechaCorte = fechaCorte };

            await apiClient.SendFechaCorteAsync(dto, ct);

            stopwatch.Stop();
            _logger.LogInformation($"   ? Fecha Corte actualizada: {fechaCorte:yyyy-MM-dd} en {stopwatch.ElapsedMilliseconds}ms");
        }
        catch (Exception ex)
        {
            stopwatch.Stop();
            _logger.LogError(ex, $"   ? Error sincronizando Fecha Corte después de {stopwatch.Elapsed.TotalSeconds:F1}s");
            throw;
        }
    }
}
