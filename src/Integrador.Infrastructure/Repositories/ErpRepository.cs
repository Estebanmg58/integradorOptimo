using System.Data;
using Dapper;
using Integrador.Core.DTOs;
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
        
        var parameters = new DynamicParameters();
        parameters.Add("@TipoConsulta", 1, DbType.Int32);
        parameters.Add("@CodigoProducto", null, DbType.Int32);
        parameters.Add("@Consecutivo", null, DbType.String);

        var result = await connection.QueryAsync<dynamic>(
            "ERP_SPConsultaDta",
            parameters,
            commandType: CommandType.StoredProcedure,
            commandTimeout: 120
        );

        return result.Select(r => new AsociadoDto
        {
            CodigoEntidad = (short)(r.CodigoEntidad ?? 0),
            Tercero = (long)(r.Tercero ?? 0),
            CodigoOficina = (short)(r.CodigoOficina ?? 0),
            Documento = r.Documento ?? string.Empty,
            PrimerNombre = r.PrimerNombre ?? string.Empty,
            SegundoNombre = r.SegundoNombre,
            PrimerApellido = r.PrimerApellido ?? string.Empty,
            SegundoApellido = r.SegundoApellido,
            Antiguedad = r.Antiguedad,
            Email = r.Email,
            Celular = r.Celular,
            Estado = r.Estado,
            FechaMatricula = r.FechaMatricula
        }).ToList();
    }

    public async Task<List<ProductoDto>> GetProductosAsync(CancellationToken ct)
    {
        using var connection = new SqlConnection(_connectionString);
        
        var parameters = new DynamicParameters();
        parameters.Add("@TipoConsulta", 2, DbType.Int32);
        parameters.Add("@CodigoProducto", null, DbType.Int32);
        parameters.Add("@Consecutivo", null, DbType.String);

        var result = await connection.QueryAsync<dynamic>(
            "ERP_SPConsultaDta",
            parameters,
            commandType: CommandType.StoredProcedure,
            commandTimeout: 120
        );

        return result.Select(r => new ProductoDto
        {
            CodigoEntidad = (short)(r.CodigoEntidad ?? 0),
            CodigoOficina = (short)(r.CodigoOficina ?? 0),
            CodigoProducto = (short)(r.CodigoProducto ?? 0),
            Consecutivo = r.Consecutivo?.ToString().Trim() ?? string.Empty,
            Tercero = (long)(r.Tercero ?? 0),
            CodigoLinea = r.CodigoLinea,
            Digito = r.Digito,
            Monto = r.Monto,
            Saldo = r.Saldo,
            Cuota = r.Cuota,
            Pagare = r.Pagare,
            Plazo = r.Plazo,
            CuotasPagas = r.CuotasPagas,
            CuotasMora = r.CuotasMora,
            FechaUltimaTrans = r.FechaUltimaTrans,
            FechaVencimiento = r.FechaVencimiento,
            Estado = r.Estado,
            FechaApertura = r.FechaApertura,
            FechaRetiro = r.FechaRetiro
        }).ToList();
    }

    public async Task<List<MovimientoDto>> GetMovimientosAsync(CancellationToken ct)
    {
        using var connection = new SqlConnection(_connectionString);
        
        var parameters = new DynamicParameters();
        parameters.Add("@TipoConsulta", 6, DbType.Int32);
        parameters.Add("@CodigoProducto", null, DbType.Int32);
        parameters.Add("@Consecutivo", null, DbType.String);

        var result = await connection.QueryAsync<dynamic>(
            "ERP_SPConsultaDta",
            parameters,
            commandType: CommandType.StoredProcedure,
            commandTimeout: 300
        );

        return result.Select(r => new MovimientoDto
        {
            Id = (int)(r.id ?? 0),
            CodigoEntidad = (short)(r.CodigoEntidad ?? 0),
            CodigoOficina = (short)(r.CodigoOficina ?? 0),
            CodigoProducto = (short)(r.CodigoProducto ?? 0),
            Consecutivo = r.Consecutivo?.ToString().Trim() ?? string.Empty,
            Fecha = r.Fecha,
            Operacion = r.Operacion ?? string.Empty,
            Naturaleza = (short)(r.Naturaleza ?? 0),
            Valor = r.Valor ?? 0m,
            Cuota = r.Cuota
        }).ToList();
    }

    public async Task<List<TasaDto>> GetTasasAsync(CancellationToken ct)
    {
        using var connection = new SqlConnection(_connectionString);
        
        var parameters = new DynamicParameters();
        parameters.Add("@TipoConsulta", 4, DbType.Int32);
        parameters.Add("@CodigoProducto", null, DbType.Int32);
        parameters.Add("@Consecutivo", null, DbType.String);

        var result = await connection.QueryAsync<dynamic>(
            "ERP_SPConsultaDta",
            parameters,
            commandType: CommandType.StoredProcedure,
            commandTimeout: 60
        );

        return result.Select(r => new TasaDto
        {
            CodigoEntidad = (short)(r.CodigoEntidad ?? 0),
            CodigoProducto = (short)(r.CodigoProducto ?? 0),
            CodigoLinea = r.CodigoLinea ?? string.Empty,
            PlazoInicial = (short)(r.PlazoInicial ?? 0),
            PlazoFinal = (short)(r.PlazoFinal ?? 0),
            MontoInicial = r.MontoInicial ?? 0m,
            MontoFinal = r.MontoFinal ?? 0m,
            Tasa = r.Tasa ?? 0.0
        }).ToList();
    }

    public async Task<DateTime> GetFechaCorteAsync(CancellationToken ct)
    {
        using var connection = new SqlConnection(_connectionString);
        
        var parameters = new DynamicParameters();
        parameters.Add("@TipoConsulta", 3, DbType.Int32);
        parameters.Add("@CodigoProducto", null, DbType.Int32);
        parameters.Add("@Consecutivo", null, DbType.String);

        var result = await connection.QueryFirstOrDefaultAsync<DateTime>(
            "ERP_SPConsultaDta",
            parameters,
            commandType: CommandType.StoredProcedure,
            commandTimeout: 30
        );

        return result;
    }
}
