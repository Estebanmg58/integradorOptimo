namespace Integrador.Core.DTOs;

public class MovimientoDto
{
    // Campos de genMovimiento según CSV
    public int Id { get; set; }                        // int NOT NULL
    public short CodigoEntidad { get; set; }           // smallint NOT NULL
    public short CodigoOficina { get; set; }           // smallint NOT NULL
    public short CodigoProducto { get; set; }          // smallint NOT NULL
    public string Consecutivo { get; set; } = string.Empty;    // varchar(15) NOT NULL
    public DateTime Fecha { get; set; }                // datetime NOT NULL
    public string Operacion { get; set; } = string.Empty;      // varchar(25) NOT NULL
    public short Naturaleza { get; set; }              // smallint NOT NULL
    public decimal Valor { get; set; }                 // money NOT NULL
    public short? Cuota { get; set; }                  // smallint NULL
}
