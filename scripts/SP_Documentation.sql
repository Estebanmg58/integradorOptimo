-- ================================================
-- DOCUMENTACIÓN DEL SP EXISTENTE: ERP_SPConsultaDta
-- ================================================
-- Este documento explica cómo usar el SP real del ERP
-- para la integración con IntegradorOptimo
-- ================================================

-- ================================================
-- TIPOS DE CONSULTA DISPONIBLES
-- ================================================

-- @TipoConsulta = 1: ASOCIADOS
-- Retorna datos de genAsociados
-- Columnas: CodigoEntidad, Tercero, CodigoOficina, Documento, PrimerNombre, SegundoNombre,
--           PrimerApellido, SegundoApellido, Antiguedad, Email, Celular, Estado, FechaMatricula

-- @TipoConsulta = 2: PRODUCTOS
-- Retorna datos de genProductos (activos, sin retiro)
-- Columnas: CodigoEntidad, CodigoOficina, CodigoProducto, Consecutivo, Tercero, CodigoLinea,
--           Digito, Monto, Saldo, Cuota, Pagare, Plazo, CuotasPagas, CuotasMora,
--           FechaUltimaTrans, FechaVencimiento, Estado, FechaApertura, FechaRetiro

-- @TipoConsulta = 3: FECHA CORTE
-- Retorna FechaCorte de admEntidades (WHERE id=1)
-- Columnas: FechaCorte

-- @TipoConsulta = 4: TASAS
-- Retorna configuración de tasas de admTasas
-- Columnas: CodigoEntidad, CodigoProducto, CodigoLinea, PlazoInicial, PlazoFinal,
--           MontoInicial, MontoFinal, Tasa

-- @TipoConsulta = 5: PRODUCTOS (LOOKUP)
-- Retorna solo Consecutivo y CodigoProducto de genProductos
-- Columnas: Consecutivo, CodigoProducto

-- @TipoConsulta = 6: MOVIMIENTOS
-- Retorna movimientos filtrados por CodigoProducto y Consecutivo
-- REQUIERE: @CodigoProducto (INT) y @Consecutivo (VARCHAR)
-- Columnas: id, CodigoEntidad, CodigoOficina, CodigoProducto, Consecutivo, Fecha,
--           Operacion, Naturaleza, Valor, Cuota

-- ================================================
-- EJEMPLOS DE USO
-- ================================================

PRINT '========================================';
PRINT 'EJEMPLOS DE USO DEL SP';
PRINT '========================================';
PRINT '';

-- ================================================
-- 1. CONSULTAR ASOCIADOS
-- ================================================
PRINT '1. Consultando Asociados...';
EXEC ERP_SPConsultaDta 
    @TipoConsulta = 1,
    @CodigoProducto = NULL,
    @Consecutivo = NULL;
PRINT '';

-- ================================================
-- 2. CONSULTAR PRODUCTOS ACTIVOS
-- ================================================
PRINT '2. Consultando Productos activos...';
EXEC ERP_SPConsultaDta 
    @TipoConsulta = 2,
    @CodigoProducto = NULL,
    @Consecutivo = NULL;
PRINT '';

-- ================================================
-- 3. CONSULTAR FECHA CORTE
-- ================================================
PRINT '3. Consultando Fecha Corte...';
EXEC ERP_SPConsultaDta 
    @TipoConsulta = 3,
    @CodigoProducto = NULL,
    @Consecutivo = NULL;
PRINT '';

-- ================================================
-- 4. CONSULTAR TASAS
-- ================================================
PRINT '4. Consultando Tasas...';
EXEC ERP_SPConsultaDta 
    @TipoConsulta = 4,
    @CodigoProducto = NULL,
    @Consecutivo = NULL;
PRINT '';

-- ================================================
-- 5. CONSULTAR PRODUCTOS (LOOKUP)
-- ================================================
PRINT '5. Consultando Productos (lookup)...';
EXEC ERP_SPConsultaDta 
    @TipoConsulta = 5,
    @CodigoProducto = NULL,
    @Consecutivo = NULL;
PRINT '';

-- ================================================
-- 6. CONSULTAR MOVIMIENTOS (requiere parámetros)
-- ================================================
PRINT '6. Consultando Movimientos de un producto específico...';
-- IMPORTANTE: Este tipo de consulta requiere CodigoProducto y Consecutivo
-- Ejemplo:
EXEC ERP_SPConsultaDta 
    @TipoConsulta = 6,
    @CodigoProducto = 1, -- Reemplazar con CodigoProducto real
    @Consecutivo = '123456'; -- Reemplazar con Consecutivo real
PRINT '';

-- ================================================
-- NOTAS IMPORTANTES PARA INTEGRADOROPTIMO
-- ================================================

PRINT '';
PRINT '========================================';
PRINT 'NOTAS IMPORTANTES:';
PRINT '========================================';
PRINT '';
PRINT '?? MOVIMIENTOS (@TipoConsulta = 6):';
PRINT '   El SP actual requiere @CodigoProducto y @Consecutivo';
PRINT '   para consultar movimientos, lo que limita obtener TODOS';
PRINT '   los movimientos de una sola vez.';
PRINT '';
PRINT '?? OPCIONES:';
PRINT '   Opción 1: Modificar el SP para agregar @TipoConsulta = 7';
PRINT '            que retorne todos los movimientos sin filtros';
PRINT '   Opción 2: Modificar @TipoConsulta = 6 para que cuando';
PRINT '            @CodigoProducto y @Consecutivo sean NULL,';
PRINT '            retorne todos los movimientos';
PRINT '   Opción 3: Agregar filtro de fecha en el Worker para';
PRINT '            limitar la cantidad de movimientos sincronizados';
PRINT '';
PRINT '? RECOMENDACIÓN:';
PRINT '   Agregar esta modificación al SP:';
PRINT '';
PRINT '   IF(@TipoConsulta = 6)';
PRINT '   BEGIN';
PRINT '       IF @CodigoProducto IS NULL AND @Consecutivo IS NULL';
PRINT '       BEGIN';
PRINT '           -- Retornar movimientos recientes (ej: últimos 3 meses)';
PRINT '           SELECT [id], [CodigoEntidad], [CodigoOficina],';
PRINT '                  [CodigoProducto], [Consecutivo], [Fecha],';
PRINT '                  [Operacion], [Naturaleza], [Valor], [Cuota]';
PRINT '           FROM [genMovimiento]';
PRINT '           WHERE [Fecha] >= DATEADD(MONTH, -3, GETDATE())';
PRINT '           ORDER BY [Fecha] DESC';
PRINT '       END';
PRINT '       ELSE';
PRINT '       BEGIN';
PRINT '           -- Consulta actual con filtros';
PRINT '           SELECT ...';
PRINT '       END';
PRINT '   END';
PRINT '';

-- ================================================
-- MAPEO DE COLUMNAS PARA DTOs
-- ================================================

PRINT '';
PRINT '========================================';
PRINT 'MAPEO DE COLUMNAS ? DTOs:';
PRINT '========================================';
PRINT '';
PRINT 'AsociadoDto:';
PRINT '  NumeroDocumento = Documento';
PRINT '  Nombres = PrimerNombre + SegundoNombre';
PRINT '  Apellidos = PrimerApellido + SegundoApellido';
PRINT '  Email = Email';
PRINT '  Celular = Celular';
PRINT '  FechaAfiliacion = FechaMatricula';
PRINT '  Estado = Estado';
PRINT '';
PRINT 'ProductoDto:';
PRINT '  NumeroDocumento = Consecutivo';
PRINT '  CodigoProducto = CodigoProducto';
PRINT '  NombreProducto = CodigoLinea';
PRINT '  Saldo = Saldo';
PRINT '  FechaApertura = FechaApertura';
PRINT '  Estado = Estado';
PRINT '';
PRINT 'MovimientoDto:';
PRINT '  NumeroDocumento = Consecutivo';
PRINT '  CodigoProducto = CodigoProducto';
PRINT '  FechaMovimiento = Fecha';
PRINT '  TipoMovimiento = Operacion';
PRINT '  Valor = Valor';
PRINT '  Descripcion = Naturaleza + Cuota';
PRINT '';
PRINT 'TasaDto:';
PRINT '  CodigoTasa = CodigoProducto';
PRINT '  NombreTasa = CodigoLinea + Plazo';
PRINT '  ValorTasa = Tasa';
PRINT '  FechaVigencia = (no disponible en SP)';
PRINT '';
PRINT 'FechaCorteDto:';
PRINT '  FechaCorte = FechaCorte';
PRINT '';

-- ================================================
-- VERIFICACIÓN RÁPIDA
-- ================================================

PRINT '========================================';
PRINT 'VERIFICACIÓN RÁPIDA:';
PRINT '========================================';
PRINT '';

-- Contar registros por tipo
DECLARE @CountAsociados INT, @CountProductos INT, @CountMovimientos INT, @CountTasas INT;

SELECT @CountAsociados = COUNT(*) FROM genAsociados;
SELECT @CountProductos = COUNT(*) FROM genProductos WHERE FechaRetiro IS NULL;
SELECT @CountMovimientos = COUNT(*) FROM genMovimiento;
SELECT @CountTasas = COUNT(*) FROM admTasas;

PRINT 'Total Asociados: ' + CAST(@CountAsociados AS VARCHAR(20));
PRINT 'Total Productos activos: ' + CAST(@CountProductos AS VARCHAR(20));
PRINT 'Total Movimientos: ' + CAST(@CountMovimientos AS VARCHAR(20));
PRINT 'Total Tasas: ' + CAST(@CountTasas AS VARCHAR(20));
PRINT '';

-- Verificar fecha corte
DECLARE @FechaCorte DATE;
SELECT @FechaCorte = FechaCorte FROM admEntidades WHERE id = 1;
PRINT 'Fecha Corte actual: ' + CAST(@FechaCorte AS VARCHAR(20));
PRINT '';

PRINT '? Verificación completada';
PRINT '';
