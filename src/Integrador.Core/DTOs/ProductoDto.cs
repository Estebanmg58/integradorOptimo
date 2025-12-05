namespace Integrador.Core.DTOs;

public class ProductoDto
{
    // Campos de genProductos según CSV
    public short CodigoEntidad { get; set; }           // smallint NOT NULL
    public short CodigoOficina { get; set; }           // smallint NOT NULL
    public short CodigoProducto { get; set; }          // smallint NOT NULL
    public string Consecutivo { get; set; } = string.Empty;    // varchar(15) NOT NULL
    public long Tercero { get; set; }                  // bigint NOT NULL
    public string? CodigoLinea { get; set; }           // varchar(10) NULL
    public short? Digito { get; set; }                 // smallint NULL
    public decimal? Monto { get; set; }                // money NULL
    public decimal? Saldo { get; set; }                // money NULL
    public decimal? Cuota { get; set; }                // money NULL
    public int? Pagare { get; set; }                   // int NULL
    public short? Plazo { get; set; }                  // smallint NULL
    public short? CuotasPagas { get; set; }            // smallint NULL
    public short? CuotasMora { get; set; }             // smallint NULL
    public DateTime? FechaUltimaTrans { get; set; }    // datetime NULL
    public DateTime? FechaVencimiento { get; set; }    // datetime NULL
    public short? Estado { get; set; }                 // smallint NULL
    public DateTime? FechaApertura { get; set; }       // datetime NULL
    public DateTime? FechaRetiro { get; set; }         // datetime NULL
}
