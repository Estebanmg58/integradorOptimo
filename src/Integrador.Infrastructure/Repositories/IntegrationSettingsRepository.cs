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
        
        var settingsDict = new Dictionary<string, string>();
        var query = "SELECT SettingKey, SettingValue FROM IntegrationSettings";
        
        var results = await connection.QueryAsync<dynamic>(query);
        
        foreach (var row in results)
        {
            settingsDict[row.SettingKey] = row.SettingValue;
        }

        return new IntegrationSettings
        {
            ScheduleCron = settingsDict.GetValueOrDefault("ScheduleCron", "0 2 * * *"),
            BatchSize = int.Parse(settingsDict.GetValueOrDefault("BatchSize", "500")),
            DailyTruncateHour = int.Parse(settingsDict.GetValueOrDefault("DailyTruncateHour", "2")),
            EnableAsociados = bool.Parse(settingsDict.GetValueOrDefault("EnableAsociados", "true")),
            EnableProductos = bool.Parse(settingsDict.GetValueOrDefault("EnableProductos", "true")),
            EnableMovimientos = bool.Parse(settingsDict.GetValueOrDefault("EnableMovimientos", "true")),
            EnableTasas = bool.Parse(settingsDict.GetValueOrDefault("EnableTasas", "true")),
            EnableFechaCorte = bool.Parse(settingsDict.GetValueOrDefault("EnableFechaCorte", "true"))
        };
    }
}
