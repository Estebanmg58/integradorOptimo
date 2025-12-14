using Integrador.Core.DTOs;

namespace Integrador.Infrastructure.Repositories;

public interface IErpRepository
{
    Task ExecuteProcesoAsync(CancellationToken ct);
    Task<List<AsociadoDto>> GetAsociadosAsync(CancellationToken ct);
    Task<List<ProductoDto>> GetProductosAsync(CancellationToken ct);
    Task<List<MovimientoDto>> GetMovimientosAsync(CancellationToken ct);
    Task<List<TasaDto>> GetTasasAsync(CancellationToken ct);
    Task<DateTime> GetFechaCorteAsync(CancellationToken ct);
}
