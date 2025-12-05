-- ================================================
-- EJEMPLO DE STORED PROCEDURE PARA EL ERP
-- ================================================
-- Este es un ejemplo de cómo debería verse el SP
-- que debe existir en tu base de datos ERP
-- ================================================
-- IMPORTANTE: Adapta este ejemplo a tu esquema real
-- ================================================

IF OBJECT_ID('ERP_SPConsultaDta', 'P') IS NOT NULL
    DROP PROCEDURE ERP_SPConsultaDta;
GO

CREATE PROCEDURE ERP_SPConsultaDta
    @TipoConsulta INT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- ===========================================
    -- @TipoConsulta = 1: ASOCIADOS
    -- ===========================================
    IF @TipoConsulta = 1
    BEGIN
        SELECT 
            NumeroDocumento = a.DocumentoIdentidad,
            Nombres = a.PrimerNombre + ' ' + ISNULL(a.SegundoNombre, ''),
            Apellidos = a.PrimerApellido + ' ' + ISNULL(a.SegundoApellido, ''),
            Email = ISNULL(a.Email, ''),
            Celular = ISNULL(a.Celular, ''),
            FechaAfiliacion = a.FechaAfiliacion,
            Estado = CASE 
                WHEN a.EstadoId = 1 THEN 'ACTIVO'
                WHEN a.EstadoId = 2 THEN 'INACTIVO'
                ELSE 'RETIRADO'
            END
        FROM 
            dbo.Asociados a
        WHERE 
            a.FechaAfiliacion >= DATEADD(YEAR, -5, GETDATE())  -- Últimos 5 años
        ORDER BY 
            a.FechaAfiliacion DESC;
            
        RETURN;
    END
    
    -- ===========================================
    -- @TipoConsulta = 2: PRODUCTOS
    -- ===========================================
    IF @TipoConsulta = 2
    BEGIN
        SELECT 
            NumeroDocumento = p.DocumentoAsociado,
            CodigoProducto = p.CodigoProducto,
            NombreProducto = tp.NombreProducto,
            Saldo = p.SaldoActual,
            FechaApertura = p.FechaApertura,
            Estado = CASE 
                WHEN p.EstadoId = 1 THEN 'ACTIVO'
                WHEN p.EstadoId = 2 THEN 'BLOQUEADO'
                ELSE 'CERRADO'
            END
        FROM 
            dbo.Productos p
            INNER JOIN dbo.TiposProducto tp ON p.TipoProductoId = tp.TipoProductoId
        WHERE 
            p.FechaApertura >= DATEADD(YEAR, -10, GETDATE())
        ORDER BY 
            p.FechaApertura DESC;
            
        RETURN;
    END
    
    -- ===========================================
    -- @TipoConsulta = 3: MOVIMIENTOS
    -- ===========================================
    IF @TipoConsulta = 3
    BEGIN
        SELECT 
            NumeroDocumento = m.DocumentoAsociado,
            CodigoProducto = m.CodigoProducto,
            FechaMovimiento = m.FechaMovimiento,
            TipoMovimiento = tm.NombreTipoMovimiento,
            Valor = m.ValorMovimiento,
            Descripcion = ISNULL(m.Descripcion, tm.NombreTipoMovimiento)
        FROM 
            dbo.Movimientos m
            INNER JOIN dbo.TiposMovimiento tm ON m.TipoMovimientoId = tm.TipoMovimientoId
        WHERE 
            m.FechaMovimiento >= DATEADD(MONTH, -3, GETDATE())  -- Últimos 3 meses
            AND m.EstadoId = 1  -- Solo movimientos confirmados
        ORDER BY 
            m.FechaMovimiento DESC;
            
        RETURN;
    END
    
    -- ===========================================
    -- @TipoConsulta = 4: TASAS
    -- ===========================================
    IF @TipoConsulta = 4
    BEGIN
        SELECT 
            CodigoTasa = t.CodigoTasa,
            NombreTasa = t.NombreTasa,
            ValorTasa = t.ValorPorcentaje,
            FechaVigencia = t.FechaVigenciaDesde
        FROM 
            dbo.TasasInteres t
        WHERE 
            t.Activo = 1
            AND t.FechaVigenciaDesde <= GETDATE()
            AND (t.FechaVigenciaHasta IS NULL OR t.FechaVigenciaHasta >= GETDATE())
        ORDER BY 
            t.FechaVigenciaDesde DESC;
            
        RETURN;
    END
    
    -- ===========================================
    -- @TipoConsulta = 5: FECHA CORTE
    -- ===========================================
    IF @TipoConsulta = 5
    BEGIN
        -- Retorna un solo valor DateTime con la fecha de corte actual
        SELECT TOP 1
            FechaCorte = fc.FechaCorte
        FROM 
            dbo.FechasCorteProceso fc
        WHERE 
            fc.TipoProceso = 'SINCRONIZACION'
            AND fc.Activo = 1
        ORDER BY 
            fc.FechaCorte DESC;
            
        -- Si no existe, retornar la fecha actual
        IF @@ROWCOUNT = 0
        BEGIN
            SELECT FechaCorte = CAST(GETDATE() AS DATE);
        END
        
        RETURN;
    END
    
    -- Tipo de consulta no válido
    RAISERROR('Tipo de consulta no válido. Valores permitidos: 1-5', 16, 1);
END
GO

-- ================================================
-- PRUEBAS DEL STORED PROCEDURE
-- ================================================

PRINT '========================================';
PRINT 'PRUEBAS DEL STORED PROCEDURE';
PRINT '========================================';
PRINT '';

-- Prueba 1: Asociados
PRINT '1. Consultando Asociados...';
EXEC ERP_SPConsultaDta @TipoConsulta = 1;
PRINT '';

-- Prueba 2: Productos
PRINT '2. Consultando Productos...';
EXEC ERP_SPConsultaDta @TipoConsulta = 2;
PRINT '';

-- Prueba 3: Movimientos
PRINT '3. Consultando Movimientos...';
EXEC ERP_SPConsultaDta @TipoConsulta = 3;
PRINT '';

-- Prueba 4: Tasas
PRINT '4. Consultando Tasas...';
EXEC ERP_SPConsultaDta @TipoConsulta = 4;
PRINT '';

-- Prueba 5: Fecha Corte
PRINT '5. Consultando Fecha Corte...';
EXEC ERP_SPConsultaDta @TipoConsulta = 5;
PRINT '';

PRINT '? Pruebas completadas';

-- ================================================
-- NOTAS IMPORTANTES:
-- ================================================
-- 1. Adapta los nombres de tablas y campos a tu esquema
-- 2. Ajusta los filtros (WHERE) según tus necesidades
-- 3. Agrega índices en las columnas de fecha para mejor performance
-- 4. Considera particionar tablas grandes (Movimientos)
-- 5. Monitorea los tiempos de ejecución en producción
-- ================================================
