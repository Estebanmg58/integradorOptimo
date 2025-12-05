namespace Integrador.Core.DTOs;

public class TasaDto
{
    // Campos de admTasas según CSV
    public short CodigoEntidad { get; set; }           // smallint NOT NULL
    public short CodigoProducto { get; set; }          // smallint NOT NULL
    public string CodigoLinea { get; set; } = string.Empty;    // varchar(6) NOT NULL
    public short PlazoInicial { get; set; }            // smallint NOT NULL
    public short PlazoFinal { get; set; }              // smallint NOT NULL
    public decimal MontoInicial { get; set; }          // money NOT NULL
    public decimal MontoFinal { get; set; }            // money NOT NULL
    public double Tasa { get; set; }                   // float NOT NULL
}
