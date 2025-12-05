using Integrador.Core.DTOs;

namespace Integrador.Worker.Services;

public interface IApiClientService
{
    Task SendAsociadosAsync(List<AsociadoDto> asociados, CancellationToken ct);
    Task SendProductosAsync(List<ProductoDto> productos, bool isFullLoad, CancellationToken ct);
    Task SendMovimientosAsync(List<MovimientoDto> movimientos, CancellationToken ct);
    Task SendTasasAsync(List<TasaDto> tasas, CancellationToken ct);
    Task SendFechaCorteAsync(FechaCorteDto fechaCorte, CancellationToken ct);
}
