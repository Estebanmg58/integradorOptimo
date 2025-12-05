namespace Integrador.Core.DTOs;

public class AsociadoDto
{
    // Campos de genAsociados según CSV
    public short CodigoEntidad { get; set; }           // smallint NOT NULL
    public long Tercero { get; set; }                  // bigint NOT NULL
    public short CodigoOficina { get; set; }           // smallint NOT NULL
    public string Documento { get; set; } = string.Empty;      // varchar(15) NOT NULL
    public string PrimerNombre { get; set; } = string.Empty;   // varchar(20) NOT NULL
    public string? SegundoNombre { get; set; }         // varchar(20) NULL
    public string PrimerApellido { get; set; } = string.Empty; // varchar(20) NOT NULL
    public string? SegundoApellido { get; set; }       // varchar(20) NULL
    public short? Antiguedad { get; set; }             // smallint NULL
    public string? Email { get; set; }                 // varchar(100) NULL
    public string? Celular { get; set; }               // varchar(12) NULL
    public short? Estado { get; set; }                 // smallint NULL
    public DateTime? FechaMatricula { get; set; }      // smalldatetime NULL
}
