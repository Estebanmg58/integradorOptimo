using System.Net.Http.Headers;
using System.Text;
using System.Text.Json;
using Integrador.Core.DTOs;
using Microsoft.Extensions.Configuration;

namespace Integrador.Worker.Services;

public class ApiClientService : IApiClientService
{
    private readonly HttpClient _httpClient;
    private readonly string _baseUrl;
    private readonly string _apiKey;
    private readonly JsonSerializerOptions _jsonOptions;

    public ApiClientService(HttpClient httpClient, IConfiguration configuration)
    {
        _httpClient = httpClient;
        _baseUrl = configuration["ApiSettings:BaseUrl"] ?? throw new ArgumentNullException("ApiSettings:BaseUrl");
        _apiKey = configuration["ApiSettings:ApiKey"] ?? throw new ArgumentNullException("ApiSettings:ApiKey");
        
        _httpClient.Timeout = TimeSpan.FromMinutes(5);
        _httpClient.DefaultRequestHeaders.Add("X-API-Key", _apiKey);
        _httpClient.DefaultRequestHeaders.Accept.Add(new MediaTypeWithQualityHeaderValue("application/json"));

        _jsonOptions = new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
            WriteIndented = false
        };
    }

    public async Task SendAsociadosAsync(List<AsociadoDto> asociados, CancellationToken ct)
    {
        var url = $"{_baseUrl}/api/integration/asociados";
        await SendDataAsync(url, asociados, ct);
    }

    public async Task SendProductosAsync(List<ProductoDto> productos, bool isFullLoad, CancellationToken ct)
    {
        var url = $"{_baseUrl}/api/integration/productos?isFullLoad={isFullLoad}";
        await SendDataAsync(url, productos, ct);
    }

    public async Task SendMovimientosAsync(List<MovimientoDto> movimientos, CancellationToken ct)
    {
        var url = $"{_baseUrl}/api/integration/movimientos";
        await SendDataAsync(url, movimientos, ct);
    }

    public async Task SendTasasAsync(List<TasaDto> tasas, CancellationToken ct)
    {
        var url = $"{_baseUrl}/api/integration/tasas";
        await SendDataAsync(url, tasas, ct);
    }

    public async Task SendFechaCorteAsync(FechaCorteDto fechaCorte, CancellationToken ct)
    {
        var url = $"{_baseUrl}/api/integration/fecha-corte";
        await SendDataAsync(url, fechaCorte, ct);
    }

    private async Task SendDataAsync<T>(string url, T data, CancellationToken ct)
    {
        var json = JsonSerializer.Serialize(data, _jsonOptions);
        var content = new StringContent(json, Encoding.UTF8, "application/json");

        var response = await _httpClient.PostAsync(url, content, ct);
        response.EnsureSuccessStatusCode();
    }
}
