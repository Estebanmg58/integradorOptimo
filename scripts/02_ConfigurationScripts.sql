-- ================================================================
-- SCRIPTS DE CONFIGURACIÓN - IntegradorOptimo
-- ================================================================
-- Usa estos scripts para configurar el horario y opciones de migración
-- ================================================================

USE IntegradorDB;
GO

PRINT '';
PRINT '???????????????????????????????????????????????????????????';
PRINT '           SCRIPTS DE CONFIGURACIÓN RÁPIDA';
PRINT '???????????????????????????????????????????????????????????';
PRINT '';

-- ================================================================
-- 1. VER CONFIGURACIÓN ACTUAL
-- ================================================================

PRINT '?? Para ver la configuración actual:';
PRINT '   EXEC sp_ViewCurrentConfiguration;';
PRINT '';

-- ================================================================
-- 2. CONFIGURAR HORARIOS DE EJECUCIÓN
-- ================================================================

PRINT '???????????????????????????????????????????????????????????';
PRINT '?? CONFIGURAR HORARIOS DE EJECUCIÓN';
PRINT '???????????????????????????????????????????????????????????';
PRINT '';

-- Diario a las 2:00 AM
PRINT '-- Ejecutar DIARIAMENTE a las 2:00 AM:';
PRINT 'EXEC sp_UpdateIntegrationSetting ''ScheduleCron'', ''0 2 * * *'';';
PRINT '';

-- Diario a las 3:00 AM
PRINT '-- Ejecutar DIARIAMENTE a las 3:00 AM:';
PRINT 'EXEC sp_UpdateIntegrationSetting ''ScheduleCron'', ''0 3 * * *'';';
PRINT '';

-- Cada 4 horas
PRINT '-- Ejecutar CADA 4 HORAS:';
PRINT 'EXEC sp_UpdateIntegrationSetting ''ScheduleCron'', ''0 */4 * * *'';';
PRINT '';

-- Cada 30 minutos
PRINT '-- Ejecutar CADA 30 MINUTOS (para pruebas):';
PRINT 'EXEC sp_UpdateIntegrationSetting ''ScheduleCron'', ''*/30 * * * *'';';
PRINT '';

-- Cada 15 minutos
PRINT '-- Ejecutar CADA 15 MINUTOS (para pruebas):';
PRINT 'EXEC sp_UpdateIntegrationSetting ''ScheduleCron'', ''*/15 * * * *'';';
PRINT '';

-- Cada 5 minutos
PRINT '-- Ejecutar CADA 5 MINUTOS (para desarrollo):';
PRINT 'EXEC sp_UpdateIntegrationSetting ''ScheduleCron'', ''*/5 * * * *'';';
PRINT '';

-- Cada 1 minuto
PRINT '-- Ejecutar CADA 1 MINUTO (solo desarrollo):';
PRINT 'EXEC sp_UpdateIntegrationSetting ''ScheduleCron'', ''*/1 * * * *'';';
PRINT '';

-- Lunes a Viernes a las 8 AM
PRINT '-- Ejecutar LUNES A VIERNES a las 8:00 AM:';
PRINT 'EXEC sp_UpdateIntegrationSetting ''ScheduleCron'', ''0 8 * * 1-5'';';
PRINT '';

-- Primer día del mes a medianoche
PRINT '-- Ejecutar PRIMER DÍA DE CADA MES a medianoche:';
PRINT 'EXEC sp_UpdateIntegrationSetting ''ScheduleCron'', ''0 0 1 * *'';';
PRINT '';

-- Domingos a las 11 PM
PRINT '-- Ejecutar DOMINGOS a las 11:00 PM:';
PRINT 'EXEC sp_UpdateIntegrationSetting ''ScheduleCron'', ''0 23 * * 0'';';
PRINT '';

-- ================================================================
-- 3. CONFIGURAR TAMAÑO DE LOTE
-- ================================================================

PRINT '???????????????????????????????????????????????????????????';
PRINT '?? CONFIGURAR TAMAÑO DE LOTE';
PRINT '???????????????????????????????????????????????????????????';
PRINT '';

PRINT '-- Lote de 500 registros (RECOMENDADO):';
PRINT 'EXEC sp_UpdateIntegrationSetting ''BatchSize'', ''500'';';
PRINT '';

PRINT '-- Lote de 1000 registros (para datasets grandes):';
PRINT 'EXEC sp_UpdateIntegrationSetting ''BatchSize'', ''1000'';';
PRINT '';

PRINT '-- Lote de 100 registros (para pruebas):';
PRINT 'EXEC sp_UpdateIntegrationSetting ''BatchSize'', ''100'';';
PRINT '';

-- ================================================================
-- 4. ACTIVAR/DESACTIVAR ENTIDADES
-- ================================================================

PRINT '???????????????????????????????????????????????????????????';
PRINT '? ACTIVAR/DESACTIVAR ENTIDADES';
PRINT '???????????????????????????????????????????????????????????';
PRINT '';

PRINT '-- ACTIVAR todas las entidades:';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableAsociados'', ''true'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableProductos'', ''true'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableMovimientos'', ''true'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableTasas'', ''true'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableFechaCorte'', ''true'';';
PRINT '';

PRINT '-- DESACTIVAR todas las entidades:';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableAsociados'', ''false'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableProductos'', ''false'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableMovimientos'', ''false'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableTasas'', ''false'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableFechaCorte'', ''false'';';
PRINT '';

PRINT '-- Sincronizar SOLO Asociados (para pruebas):';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableAsociados'', ''true'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableProductos'', ''false'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableMovimientos'', ''false'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableTasas'', ''false'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableFechaCorte'', ''false'';';
PRINT '';

PRINT '-- Sincronizar SOLO Productos (para pruebas):';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableAsociados'', ''false'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableProductos'', ''true'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableMovimientos'', ''false'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableTasas'', ''false'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableFechaCorte'', ''false'';';
PRINT '';

-- ================================================================
-- 5. CONFIGURAR HORA DE CARGA COMPLETA
-- ================================================================

PRINT '???????????????????????????????????????????????????????????';
PRINT '?? CONFIGURAR HORA DE CARGA COMPLETA (FullLoad)';
PRINT '???????????????????????????????????????????????????????????';
PRINT '';

PRINT '-- FullLoad a las 2 AM (recomendado):';
PRINT 'EXEC sp_UpdateIntegrationSetting ''DailyTruncateHour'', ''2'';';
PRINT '';

PRINT '-- FullLoad a las 3 AM:';
PRINT 'EXEC sp_UpdateIntegrationSetting ''DailyTruncateHour'', ''3'';';
PRINT '';

PRINT '-- Deshabilitar FullLoad (siempre incremental):';
PRINT 'EXEC sp_UpdateIntegrationSetting ''DailyTruncateHour'', ''-1'';';
PRINT '';

-- ================================================================
-- 6. CONSULTAS DE MONITOREO
-- ================================================================

PRINT '???????????????????????????????????????????????????????????';
PRINT '?? CONSULTAS DE MONITOREO';
PRINT '???????????????????????????????????????????????????????????';
PRINT '';

PRINT '-- Ver últimas 20 ejecuciones:';
PRINT 'SELECT TOP 20 * FROM vw_RecentExecutions ORDER BY Id DESC;';
PRINT '';

PRINT '-- Ver ejecuciones exitosas del último mes:';
PRINT 'SELECT * FROM IntegrationExecutionHistory';
PRINT 'WHERE Estado = ''Success''';
PRINT '  AND FechaInicio >= DATEADD(MONTH, -1, GETDATE())';
PRINT 'ORDER BY FechaInicio DESC;';
PRINT '';

PRINT '-- Ver ejecuciones con errores:';
PRINT 'SELECT * FROM IntegrationExecutionHistory';
PRINT 'WHERE Estado = ''Error''';
PRINT 'ORDER BY FechaInicio DESC;';
PRINT '';

PRINT '-- Estadísticas de performance:';
PRINT 'SELECT ';
PRINT '    COUNT(*) AS TotalEjecuciones,';
PRINT '    AVG(DuracionSegundos) AS PromedioSegundos,';
PRINT '    MIN(DuracionSegundos) AS MinSegundos,';
PRINT '    MAX(DuracionSegundos) AS MaxSegundos,';
PRINT '    AVG(AsociadosProcesados + ProductosProcesados + MovimientosProcesados) AS PromedioRegistros';
PRINT 'FROM IntegrationExecutionHistory';
PRINT 'WHERE Estado = ''Success''';
PRINT '  AND FechaInicio >= DATEADD(DAY, -7, GETDATE());';
PRINT '';

-- ================================================================
-- 7. SCRIPTS DE MANTENIMIENTO
-- ================================================================

PRINT '???????????????????????????????????????????????????????????';
PRINT '?? SCRIPTS DE MANTENIMIENTO';
PRINT '???????????????????????????????????????????????????????????';
PRINT '';

PRINT '-- Limpiar historial mayor a 90 días:';
PRINT 'DELETE FROM IntegrationExecutionHistory';
PRINT 'WHERE FechaInicio < DATEADD(DAY, -90, GETDATE());';
PRINT '';

PRINT '-- Ver tamaño de las tablas:';
PRINT 'SELECT ';
PRINT '    t.NAME AS TableName,';
PRINT '    p.rows AS RowCounts,';
PRINT '    SUM(a.total_pages) * 8 AS TotalSpaceKB, ';
PRINT '    SUM(a.used_pages) * 8 AS UsedSpaceKB ';
PRINT 'FROM sys.tables t';
PRINT 'INNER JOIN sys.indexes i ON t.OBJECT_ID = i.object_id';
PRINT 'INNER JOIN sys.partitions p ON i.object_id = p.OBJECT_ID AND i.index_id = p.index_id';
PRINT 'INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id';
PRINT 'WHERE t.is_ms_shipped = 0';
PRINT 'GROUP BY t.Name, p.Rows';
PRINT 'ORDER BY TotalSpaceKB DESC;';
PRINT '';

-- ================================================================
-- 8. EJEMPLOS DE USO COMPLETO
-- ================================================================

PRINT '???????????????????????????????????????????????????????????';
PRINT '?? EJEMPLOS DE USO COMPLETO';
PRINT '???????????????????????????????????????????????????????????';
PRINT '';

PRINT '-- Ejemplo 1: Configuración para PRODUCCIÓN';
PRINT '-- (Ejecución diaria a las 2 AM, todas las entidades activas)';
PRINT '';
PRINT 'EXEC sp_UpdateIntegrationSetting ''ScheduleCron'', ''0 2 * * *'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''BatchSize'', ''500'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''DailyTruncateHour'', ''2'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableAsociados'', ''true'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableProductos'', ''true'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableMovimientos'', ''true'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableTasas'', ''true'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableFechaCorte'', ''true'';';
PRINT 'EXEC sp_ViewCurrentConfiguration;';
PRINT '';

PRINT '-- Ejemplo 2: Configuración para PRUEBAS';
PRINT '-- (Ejecución cada 15 minutos, solo Asociados)';
PRINT '';
PRINT 'EXEC sp_UpdateIntegrationSetting ''ScheduleCron'', ''*/15 * * * *'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''BatchSize'', ''100'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableAsociados'', ''true'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableProductos'', ''false'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableMovimientos'', ''false'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableTasas'', ''false'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableFechaCorte'', ''false'';';
PRINT 'EXEC sp_ViewCurrentConfiguration;';
PRINT '';

PRINT '-- Ejemplo 3: Configuración para DESARROLLO';
PRINT '-- (Ejecución cada 5 minutos, lotes pequeños)';
PRINT '';
PRINT 'EXEC sp_UpdateIntegrationSetting ''ScheduleCron'', ''*/5 * * * *'';';
PRINT 'EXEC sp_UpdateIntegrationSetting ''BatchSize'', ''50'';';
PRINT 'EXEC sp_ViewCurrentConfiguration;';
PRINT '';

PRINT '???????????????????????????????????????????????????????????';
PRINT '';

-- ================================================================
-- 9. REFERENCIA DE CRON EXPRESSIONS
-- ================================================================

PRINT '???????????????????????????????????????????????????????????';
PRINT '?? REFERENCIA RÁPIDA DE CRON EXPRESSIONS';
PRINT '???????????????????????????????????????????????????????????';
PRINT '';
PRINT 'Formato: [minuto] [hora] [día del mes] [mes] [día semana]';
PRINT '';
PRINT 'Ejemplos:';
PRINT '  ''0 2 * * *''       - Todos los días a las 2:00 AM';
PRINT '  ''0 */4 * * *''     - Cada 4 horas';
PRINT '  ''*/30 * * * *''    - Cada 30 minutos';
PRINT '  ''0 8-18 * * 1-5''  - Lun-Vie cada hora de 8 AM a 6 PM';
PRINT '  ''0 0 * * 0''       - Domingos a medianoche';
PRINT '  ''0 0 1 * *''       - Primer día de cada mes';
PRINT '  ''0 12 * * 1,3,5''  - Lun/Mié/Vie a las 12:00 PM';
PRINT '';
PRINT 'Validar en: https://crontab.guru/';
PRINT '';
PRINT '???????????????????????????????????????????????????????????';
PRINT '';
