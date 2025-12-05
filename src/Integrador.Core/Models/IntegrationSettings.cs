namespace Integrador.Core.Models;

public class IntegrationSettings
{
    public string ScheduleCron { get; set; } = "0 2 * * *";
    public int BatchSize { get; set; } = 500;
    public int DailyTruncateHour { get; set; } = 2;
    public bool EnableAsociados { get; set; } = true;
    public bool EnableProductos { get; set; } = true;
    public bool EnableMovimientos { get; set; } = true;
    public bool EnableTasas { get; set; } = true;
    public bool EnableFechaCorte { get; set; } = true;
}
