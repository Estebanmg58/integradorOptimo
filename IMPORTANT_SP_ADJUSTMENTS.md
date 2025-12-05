# ?? IMPORTANTE - Ajustes para tu SP Real

## ?? **DIFERENCIAS ENCONTRADAS**

Tu SP `ERP_SPConsultaDta` tiene **diferencias importantes** con el diseño original. Aquí está el análisis:

---

## ?? **MAPEO DE @TipoConsulta**

### **En el Diseño Original:**
| @TipoConsulta | Entidad |
|---------------|---------|
| 1 | Asociados |
| 2 | Productos |
| 3 | Movimientos |
| 4 | Tasas |
| 5 | Fecha Corte |

### **En tu SP Real:**
| @TipoConsulta | Entidad | Tabla | Notas |
|---------------|---------|-------|-------|
| 1 | Asociados | `genAsociados` | ? OK |
| 2 | Productos | `genProductos` | ? OK (filtrado sin retiros) |
| 3 | **Fecha Corte** | `admEntidades` | ?? Diferente posición |
| 4 | Tasas | `admTasas` | ? OK |
| 5 | Productos (lookup) | `genProductos` | ?? Solo Consecutivo/Codigo |
| 6 | **Movimientos** | `genMovimiento` | ? Requiere parámetros |

---

## ?? **PROBLEMA CRÍTICO: MOVIMIENTOS**

### **El Problema:**
Tu SP requiere `@CodigoProducto` y `@Consecutivo` para consultar movimientos:

```sql
IF(@TipoConsulta = 6)
BEGIN
    SELECT ...
    FROM [genMovimiento]
    WHERE [CodigoProducto] = @CodigoProducto
    AND   Consecutivo LIKE '%'+@Consecutivo+'%'; 
END
```

**Esto significa que NO puedes obtener TODOS los movimientos de una sola vez.**

### **Soluciones Posibles:**

#### **Opción 1: Modificar el SP (RECOMENDADO)**

Agrega esta lógica al SP:

```sql
IF(@TipoConsulta = 6)
BEGIN
    IF @CodigoProducto IS NULL AND @Consecutivo IS NULL
    BEGIN
        -- Retornar todos los movimientos recientes (últimos 3 meses)
        SELECT [id]
              ,[CodigoEntidad]
              ,[CodigoOficina]
              ,[CodigoProducto]
              ,[Consecutivo]
              ,[Fecha]
              ,[Operacion]
              ,[Naturaleza]
              ,[Valor]
              ,[Cuota]
        FROM [genMovimiento]
        WHERE [Fecha] >= DATEADD(MONTH, -3, GETDATE())
        ORDER BY [Fecha] DESC
    END
    ELSE
    BEGIN
        -- Consulta original con filtros
        SELECT [id]
              ,[CodigoEntidad]
              ,[CodigoOficina]
              ,[CodigoProducto]
              ,[Consecutivo]
              ,[Fecha]
              ,[Operacion]
              ,[Naturaleza]
              ,[Valor]
              ,[Cuota]
        FROM [genMovimiento]
        WHERE [CodigoProducto] = @CodigoProducto
        AND   Consecutivo LIKE '%'+@Consecutivo+'%'
    END
END
```

#### **Opción 2: Crear un nuevo TipoConsulta = 7**

```sql
IF(@TipoConsulta = 7)
BEGIN
    -- Movimientos recientes para sincronización
    SELECT [id]
          ,[CodigoEntidad]
          ,[CodigoOficina]
          ,[CodigoProducto]
          ,[Consecutivo]
          ,[Fecha]
          ,[Operacion]
          ,[Naturaleza]
          ,[Valor]
          ,[Cuota]
    FROM [genMovimiento]
    WHERE [Fecha] >= DATEADD(MONTH, -3, GETDATE())
    ORDER BY [Fecha] DESC
END
```

Luego actualiza `ErpRepository.cs`:
```csharp
parameters.Add("@TipoConsulta", 7, DbType.Int32); // En lugar de 6
```

#### **Opción 3: Deshabilitar Movimientos Temporalmente**

Hasta que modifiques el SP:

```sql
EXEC sp_UpdateIntegrationSetting 'EnableMovimientos', 'false';
```

---

## ?? **MAPEO DE COLUMNAS**

### **AsociadoDto**
```csharp
NumeroDocumento = Documento
Nombres = PrimerNombre + SegundoNombre
Apellidos = PrimerApellido + SegundoApellido
Email = Email
Celular = Celular
FechaAfiliacion = FechaMatricula
Estado = Estado
```

### **ProductoDto**
```csharp
NumeroDocumento = Consecutivo (limpio con Trim)
CodigoProducto = CodigoProducto
NombreProducto = CodigoLinea
Saldo = Saldo
FechaApertura = FechaApertura
Estado = Estado
```

### **MovimientoDto**
```csharp
NumeroDocumento = Consecutivo
CodigoProducto = CodigoProducto
FechaMovimiento = Fecha
TipoMovimiento = Operacion
Valor = Valor
Descripcion = Naturaleza + " - Cuota: " + Cuota
```

### **TasaDto**
```csharp
CodigoTasa = CodigoProducto
NombreTasa = CodigoLinea + " - Plazo: " + PlazoInicial + "-" + PlazoFinal
ValorTasa = Tasa
FechaVigencia = DateTime.Now // ?? No disponible en tu SP
```

### **FechaCorteDto**
```csharp
FechaCorte = FechaCorte (de admEntidades WHERE id=1)
```

---

## ?? **SCRIPT SQL PARA MODIFICAR TU SP**

### **Agregar Lógica para Movimientos sin Filtros:**

```sql
-- ================================================
-- Modificación del SP para soportar sincronización
-- ================================================

ALTER PROCEDURE [dbo].[ERP_SPConsultaDta]
    @TipoConsulta INT,
    @CodigoProducto INT = NULL,
    @Consecutivo VARCHAR(15) = NULL
AS
BEGIN
    -- ... (código existente para @TipoConsulta 1-5) ...

    IF(@TipoConsulta = 6)
    BEGIN
        IF @CodigoProducto IS NULL AND @Consecutivo IS NULL
        BEGIN
            -- Sincronización: Retornar movimientos recientes (últimos 3 meses)
            SELECT [id]
                  ,[CodigoEntidad]
                  ,[CodigoOficina]
                  ,[CodigoProducto]
                  ,[Consecutivo]
                  ,[Fecha]
                  ,[Operacion]
                  ,[Naturaleza]
                  ,[Valor]
                  ,[Cuota]
            FROM [genMovimiento]
            WHERE [Fecha] >= DATEADD(MONTH, -3, GETDATE())
            ORDER BY [Fecha] DESC
        END
        ELSE
        BEGIN
            -- Consulta original con filtros específicos
            SELECT [id]
                  ,[CodigoEntidad]
                  ,[CodigoOficina]
                  ,[CodigoProducto]
                  ,[Consecutivo]
                  ,[Fecha]
                  ,[Operacion]
                  ,[Naturaleza]
                  ,[Valor]
                  ,[Cuota]
            FROM [genMovimiento]
            WHERE (@CodigoProducto IS NULL OR [CodigoProducto] = @CodigoProducto)
            AND   (@Consecutivo IS NULL OR Consecutivo LIKE '%'+@Consecutivo+'%')
        END
    END
END
GO
```

---

## ? **PASOS PARA IMPLEMENTAR**

### **1. Modificar el SP (RECOMENDADO)**

```sql
-- Ejecutar el script de modificación arriba
-- Esto permitirá obtener todos los movimientos cuando los parámetros sean NULL
```

### **2. Verificar la Modificación**

```sql
-- Probar sin parámetros (debe retornar movimientos recientes)
EXEC ERP_SPConsultaDta 
    @TipoConsulta = 6,
    @CodigoProducto = NULL,
    @Consecutivo = NULL;

-- Debe retornar movimientos de los últimos 3 meses
```

### **3. Compilar el Proyecto**

```powershell
dotnet build -c Release
```

### **4. Reinstalar el Servicio**

```powershell
.\Install-Service.ps1 -Action uninstall
.\Install-Service.ps1 -Action install
```

### **5. Habilitar Movimientos**

```sql
EXEC sp_UpdateIntegrationSetting 'EnableMovimientos', 'true';
```

---

## ?? **VERIFICACIÓN POST-INSTALACIÓN**

### **Verificar que todo funciona:**

```powershell
# 1. Ver logs en tiempo real
.\Install-Service.ps1 -Action logs

# 2. Buscar errores
Get-Content C:\Logs\IntegradorOptimo\log-*.txt | Select-String "ERROR|Exception"

# 3. Verificar sincronización de movimientos
Get-Content C:\Logs\IntegradorOptimo\log-*.txt | Select-String "Sincronizando Movimientos"
```

---

## ?? **ESTADO ACTUAL DEL CÓDIGO**

### **? YA ACTUALIZADO:**
- ? `ErpRepository.cs` - Usa @TipoConsulta = 6 para movimientos
- ? Mapeo de columnas según tu estructura real
- ? Manejo de valores NULL y Trim() en Consecutivo

### **?? PENDIENTE:**
- ?? Modificar el SP para permitir consulta sin filtros
- ?? Probar con datos reales
- ?? Ajustar rango de fechas de movimientos si es necesario

---

## ?? **RECOMENDACIÓN FINAL**

**Para producción, modifica el SP con la lógica sugerida.** Esto permitirá:

1. ? Obtener todos los movimientos recientes (últimos 3 meses)
2. ? Mantener compatibilidad con consultas filtradas
3. ? Controlar el volumen sincronizado (evitar millones de registros)
4. ? Performance óptimo con índice en columna Fecha

### **Índice Recomendado:**

```sql
-- Mejorar performance de consulta de movimientos
CREATE NONCLUSTERED INDEX IX_genMovimiento_Fecha
ON [genMovimiento] ([Fecha] DESC)
INCLUDE ([CodigoProducto], [Consecutivo], [Operacion], [Valor]);
```

---

## ?? **¿NECESITAS AYUDA?**

Si tienes dudas sobre cómo modificar el SP:

1. **Copia el script de modificación** de arriba
2. **Pruébalo en ambiente de desarrollo** primero
3. **Verifica que retorna datos** con `EXEC ERP_SPConsultaDta @TipoConsulta = 6, @CodigoProducto = NULL, @Consecutivo = NULL`
4. **Despliega a producción** cuando esté probado

---

**Fecha**: 5 de Enero de 2025  
**Versión**: 1.1.1  
**Ajustes**: Compatibilidad con SP real del cliente  
**Estado**: ?? Requiere modificación del SP para movimientos  

?? **¡Una vez ajustado el SP, todo quedará melo caramelo!** ??
