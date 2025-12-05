-- ================================================
-- Script de Configuración IntegradorOptimo
-- ================================================
-- Este script debe ejecutarse en la base de datos destino
-- que configuraste en appsettings.json -> DestinationDatabase
-- ================================================

-- Crear tabla de configuración
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'IntegrationSettings')
BEGIN
    CREATE TABLE IntegrationSettings (
        Id INT PRIMARY KEY IDENTITY(1,1),
        SettingKey NVARCHAR(100) NOT NULL UNIQUE,
        SettingValue NVARCHAR(500) NOT NULL,
        LastModified DATETIME2 DEFAULT GETDATE()
    );
    
    PRINT '? Tabla IntegrationSettings creada exitosamente';
END
ELSE
BEGIN
    PRINT '?? Tabla IntegrationSettings ya existe';
END
GO

-- Insertar configuración inicial
IF NOT EXISTS (SELECT * FROM IntegrationSettings WHERE SettingKey = 'ScheduleCron')
BEGIN
    INSERT INTO IntegrationSettings (SettingKey, SettingValue) VALUES
    ('ScheduleCron', '0 2 * * *'),              -- Ejecutar a las 2:00 AM diariamente
    ('BatchSize', '500'),                        -- 500 registros por batch
    ('DailyTruncateHour', '2'),                 -- Hora para FullLoad de productos (2 AM)
    ('EnableAsociados', 'true'),                -- Sincronizar Asociados
    ('EnableProductos', 'true'),                -- Sincronizar Productos
    ('EnableMovimientos', 'true'),              -- Sincronizar Movimientos
    ('EnableTasas', 'true'),                    -- Sincronizar Tasas
    ('EnableFechaCorte', 'true');               -- Sincronizar Fecha Corte
    
    PRINT '? Configuración inicial insertada exitosamente';
END
ELSE
BEGIN
    PRINT '?? Configuración ya existe, no se insertó nada';
END
GO

-- Verificar configuración
PRINT '';
PRINT '========================================';
PRINT 'CONFIGURACIÓN ACTUAL:';
PRINT '========================================';
SELECT 
    SettingKey AS [Clave],
    SettingValue AS [Valor],
    LastModified AS [Última Modificación]
FROM IntegrationSettings
ORDER BY SettingKey;
GO

PRINT '';
PRINT '========================================';
PRINT 'EJEMPLOS DE CRON EXPRESSIONS:';
PRINT '========================================';
PRINT '0 2 * * *     -> Diario a las 2:00 AM';
PRINT '0 */4 * * *   -> Cada 4 horas';
PRINT '0 0 * * 1     -> Todos los lunes a medianoche';
PRINT '*/30 * * * *  -> Cada 30 minutos';
PRINT '0 8-18 * * 1-5 -> De lunes a viernes, cada hora de 8 AM a 6 PM';
PRINT '========================================';
GO

-- Procedimiento para actualizar configuración
IF OBJECT_ID('sp_UpdateIntegrationSetting', 'P') IS NOT NULL
    DROP PROCEDURE sp_UpdateIntegrationSetting;
GO

CREATE PROCEDURE sp_UpdateIntegrationSetting
    @SettingKey NVARCHAR(100),
    @SettingValue NVARCHAR(500)
AS
BEGIN
    UPDATE IntegrationSettings
    SET SettingValue = @SettingValue,
        LastModified = GETDATE()
    WHERE SettingKey = @SettingKey;
    
    IF @@ROWCOUNT > 0
        PRINT '? ' + @SettingKey + ' actualizado a: ' + @SettingValue;
    ELSE
        PRINT '? No se encontró la configuración: ' + @SettingKey;
END
GO

PRINT '';
PRINT '? Script completado exitosamente';
PRINT '';
PRINT 'Para cambiar la configuración, usa:';
PRINT 'EXEC sp_UpdateIntegrationSetting ''ScheduleCron'', ''0 3 * * *''';
PRINT 'EXEC sp_UpdateIntegrationSetting ''BatchSize'', ''1000''';
PRINT 'EXEC sp_UpdateIntegrationSetting ''EnableMovimientos'', ''false''';
