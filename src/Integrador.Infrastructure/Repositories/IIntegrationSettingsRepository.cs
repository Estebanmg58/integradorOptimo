using Integrador.Core.Models;

namespace Integrador.Infrastructure.Repositories;

public interface IIntegrationSettingsRepository
{
    Task<IntegrationSettings> GetSettingsAsync();
}
