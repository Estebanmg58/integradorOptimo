-- ================================================================
-- SCRIPT COMPLETO DE BASE DE DATOS - IntegradorOptimo
-- ================================================================
-- Este script crea todas las tablas, stored procedures y configuraciones
-- necesarias para que el Worker Service funcione correctamente.
-- ================================================================

USE master;
GO

-- ================================================================
-- 1. CREAR BASE DE DATOS DE CONFIGURACIÓN (si no existe)
-- ================================================================

IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'IntegradorDB')
BEGIN
    CREATE DATABASE IntegradorDB;
    PRINT '? Base de datos IntegradorDB creada';
END
ELSE
BEGIN
    PRINT '??  Base de datos IntegradorDB ya existe';
END
GO

USE IntegradorDB;
GO

-- ================================================================
-- 2. CREAR TABLA DE CONFIGURACIÓN
-- ================================================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[IntegrationSettings]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[IntegrationSettings]
    (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [SettingKey] VARCHAR(100) NOT NULL UNIQUE,
        [SettingValue] VARCHAR(500) NULL,
        [Description] VARCHAR(500) NULL,
        [FechaCreacion] DATETIME DEFAULT GETDATE(),
        [FechaActualizacion] DATETIME DEFAULT GETDATE()
    );

    PRINT '? Tabla IntegrationSettings creada';
END
ELSE
BEGIN
    PRINT '??  Tabla IntegrationSettings ya existe';
END
GO

-- ================================================================
-- 3. INSERTAR CONFIGURACIÓN INICIAL
-- ================================================================

-- Limpiar configuración existente (opcional)
-- DELETE FROM IntegrationSettings;

-- Configuración inicial
IF NOT EXISTS (SELECT * FROM IntegrationSettings WHERE SettingKey = 'ScheduleCron')
BEGIN
    INSERT INTO IntegrationSettings (SettingKey, SettingValue, Description)
    VALUES 
        -- Horario de ejecución (Cron expression)
        ('ScheduleCron', '0 2 * * *', 'Horario de ejecución diaria (2:00 AM todos los días)'),
        
        -- Tamaño de lote para envío
        ('BatchSize', '500', 'Cantidad de registros por lote (500 es óptimo)'),
        
        -- Hora del día para carga completa de productos
        ('DailyTruncateHour', '2', 'Hora del día (0-23) para marcar productos como FullLoad'),
        
        -- Activar/Desactivar entidades
        ('EnableAsociados', 'true', 'Activar sincronización de Asociados'),
        ('EnableProductos', 'true', 'Activar sincronización de Productos'),
        ('EnableMovimientos', 'true', 'Activar sincronización de Movimientos'),
        ('EnableTasas', 'true', 'Activar sincronización de Tasas'),
        ('EnableFechaCorte', 'true', 'Activar sincronización de Fecha de Corte');

    PRINT '? Configuración inicial insertada';
END
ELSE
BEGIN
    PRINT '??  Configuración inicial ya existe';
END
GO

-- ================================================================
-- 4. STORED PROCEDURE PARA OBTENER CONFIGURACIÓN
-- ================================================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_GetIntegrationSettings]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_GetIntegrationSettings];
GO

CREATE PROCEDURE [dbo].[sp_GetIntegrationSettings]
AS
BEGIN
    SET NOCOUNT ON;
    
    SELECT 
        [SettingKey],
        [SettingValue],
        [Description],
        [FechaActualizacion]
    FROM [dbo].[IntegrationSettings]
    ORDER BY [SettingKey];
END
GO

PRINT '? SP sp_GetIntegrationSettings creado';
GO

-- ================================================================
-- 5. STORED PROCEDURE PARA ACTUALIZAR CONFIGURACIÓN
-- ================================================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_UpdateIntegrationSetting]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_UpdateIntegrationSetting];
GO

CREATE PROCEDURE [dbo].[sp_UpdateIntegrationSetting]
    @SettingKey VARCHAR(100),
    @SettingValue VARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Validar que la clave existe
        IF NOT EXISTS (SELECT 1 FROM IntegrationSettings WHERE SettingKey = @SettingKey)
        BEGIN
            RAISERROR('La clave de configuración "%s" no existe', 16, 1, @SettingKey);
            RETURN;
        END
        
        -- Actualizar configuración
        UPDATE [dbo].[IntegrationSettings]
        SET 
            [SettingValue] = @SettingValue,
            [FechaActualizacion] = GETDATE()
        WHERE [SettingKey] = @SettingKey;
        
        COMMIT TRANSACTION;
        
        PRINT '? Configuración "' + @SettingKey + '" actualizada a: ' + @SettingValue;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR(@ErrorMessage, 16, 1);
    END CATCH
END
GO

PRINT '? SP sp_UpdateIntegrationSetting creado';
GO

-- ================================================================
-- 6. STORED PROCEDURE PARA VER CONFIGURACIÓN ACTUAL
-- ================================================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_ViewCurrentConfiguration]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_ViewCurrentConfiguration];
GO

CREATE PROCEDURE [dbo].[sp_ViewCurrentConfiguration]
AS
BEGIN
    SET NOCOUNT ON;
    
    PRINT '';
    PRINT '???????????????????????????????????????????????????????????';
    PRINT '          CONFIGURACIÓN ACTUAL - INTEGRADOR ÓPTIMO';
    PRINT '???????????????????????????????????????????????????????????';
    PRINT '';
    
    -- Horario de ejecución
    DECLARE @ScheduleCron VARCHAR(100);
    SELECT @ScheduleCron = SettingValue FROM IntegrationSettings WHERE SettingKey = 'ScheduleCron';
    PRINT '?? HORARIO DE EJECUCIÓN:';
    PRINT '   Cron Expression: ' + @ScheduleCron;
    
    -- Decodificar Cron
    IF @ScheduleCron = '0 2 * * *'
        PRINT '   ?? Todos los días a las 2:00 AM';
    ELSE IF @ScheduleCron LIKE '*/% * * * *'
        PRINT '   ?? Cada ' + SUBSTRING(@ScheduleCron, 3, CHARINDEX(' ', @ScheduleCron, 3) - 3) + ' minutos';
    ELSE IF @ScheduleCron LIKE '0 */% * * *'
        PRINT '   ?? Cada ' + SUBSTRING(@ScheduleCron, 5, CHARINDEX(' ', @ScheduleCron, 5) - 5) + ' horas';
    
    PRINT '';
    
    -- Tamaño de lote
    DECLARE @BatchSize VARCHAR(100);
    SELECT @BatchSize = SettingValue FROM IntegrationSettings WHERE SettingKey = 'BatchSize';
    PRINT '?? TAMAÑO DE LOTE: ' + @BatchSize + ' registros';
    PRINT '';
    
    -- Entidades activas
    PRINT '? ENTIDADES ACTIVAS:';
    
    DECLARE @EnableAsociados VARCHAR(10), @EnableProductos VARCHAR(10), @EnableMovimientos VARCHAR(10), 
            @EnableTasas VARCHAR(10), @EnableFechaCorte VARCHAR(10);
    
    SELECT @EnableAsociados = SettingValue FROM IntegrationSettings WHERE SettingKey = 'EnableAsociados';
    SELECT @EnableProductos = SettingValue FROM IntegrationSettings WHERE SettingKey = 'EnableProductos';
    SELECT @EnableMovimientos = SettingValue FROM IntegrationSettings WHERE SettingKey = 'EnableMovimientos';
    SELECT @EnableTasas = SettingValue FROM IntegrationSettings WHERE SettingKey = 'EnableTasas';
    SELECT @EnableFechaCorte = SettingValue FROM IntegrationSettings WHERE SettingKey = 'EnableFechaCorte';
    
    IF @EnableAsociados = 'true'
        PRINT '   ? Asociados';
    ELSE
        PRINT '   ? Asociados (DESACTIVADO)';
        
    IF @EnableProductos = 'true'
        PRINT '   ? Productos';
    ELSE
        PRINT '   ? Productos (DESACTIVADO)';
        
    IF @EnableMovimientos = 'true'
        PRINT '   ? Movimientos';
    ELSE
        PRINT '   ? Movimientos (DESACTIVADO)';
        
    IF @EnableTasas = 'true'
        PRINT '   ? Tasas';
    ELSE
        PRINT '   ? Tasas (DESACTIVADO)';
        
    IF @EnableFechaCorte = 'true'
        PRINT '   ? Fecha de Corte';
    ELSE
        PRINT '   ? Fecha de Corte (DESACTIVADO)';
    
    PRINT '';
    PRINT '???????????????????????????????????????????????????????????';
    PRINT '';
    
    -- Mostrar tabla completa
    SELECT 
        SettingKey AS 'Configuración',
        SettingValue AS 'Valor',
        Description AS 'Descripción',
        CONVERT(VARCHAR, FechaActualizacion, 120) AS 'Última Actualización'
    FROM IntegrationSettings
    ORDER BY 
        CASE SettingKey
            WHEN 'ScheduleCron' THEN 1
            WHEN 'BatchSize' THEN 2
            WHEN 'DailyTruncateHour' THEN 3
            ELSE 4
        END,
        SettingKey;
END
GO

PRINT '? SP sp_ViewCurrentConfiguration creado';
GO

-- ================================================================
-- 7. TABLA DE HISTORIAL DE EJECUCIONES (OPCIONAL)
-- ================================================================

IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[IntegrationExecutionHistory]') AND type in (N'U'))
BEGIN
    CREATE TABLE [dbo].[IntegrationExecutionHistory]
    (
        [Id] INT IDENTITY(1,1) PRIMARY KEY,
        [FechaInicio] DATETIME NOT NULL,
        [FechaFin] DATETIME NULL,
        [DuracionSegundos] DECIMAL(10,2) NULL,
        [Estado] VARCHAR(50) NOT NULL, -- 'Success', 'Error', 'Running'
        [AsociadosProcesados] INT NULL,
        [ProductosProcesados] INT NULL,
        [MovimientosProcesados] INT NULL,
        [TasasProcesadas] INT NULL,
        [ErrorMessage] VARCHAR(MAX) NULL,
        [ScheduleCron] VARCHAR(100) NULL,
        [BatchSize] INT NULL
    );

    CREATE INDEX IX_IntegrationExecutionHistory_FechaInicio 
    ON IntegrationExecutionHistory(FechaInicio DESC);

    PRINT '? Tabla IntegrationExecutionHistory creada';
END
ELSE
BEGIN
    PRINT '??  Tabla IntegrationExecutionHistory ya existe';
END
GO

-- ================================================================
-- 8. SP PARA REGISTRAR INICIO DE EJECUCIÓN
-- ================================================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_LogExecutionStart]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_LogExecutionStart];
GO

CREATE PROCEDURE [dbo].[sp_LogExecutionStart]
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ScheduleCron VARCHAR(100), @BatchSize INT;
    
    SELECT @ScheduleCron = SettingValue FROM IntegrationSettings WHERE SettingKey = 'ScheduleCron';
    SELECT @BatchSize = CAST(SettingValue AS INT) FROM IntegrationSettings WHERE SettingKey = 'BatchSize';
    
    INSERT INTO IntegrationExecutionHistory 
        (FechaInicio, Estado, ScheduleCron, BatchSize)
    VALUES 
        (GETDATE(), 'Running', @ScheduleCron, @BatchSize);
    
    SELECT SCOPE_IDENTITY() AS ExecutionId;
END
GO

PRINT '? SP sp_LogExecutionStart creado';
GO

-- ================================================================
-- 9. SP PARA REGISTRAR FIN DE EJECUCIÓN
-- ================================================================

IF EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[sp_LogExecutionEnd]') AND type in (N'P', N'PC'))
    DROP PROCEDURE [dbo].[sp_LogExecutionEnd];
GO

CREATE PROCEDURE [dbo].[sp_LogExecutionEnd]
    @ExecutionId INT,
    @Estado VARCHAR(50),
    @AsociadosProcesados INT = NULL,
    @ProductosProcesados INT = NULL,
    @MovimientosProcesados INT = NULL,
    @TasasProcesadas INT = NULL,
    @ErrorMessage VARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @FechaInicio DATETIME;
    SELECT @FechaInicio = FechaInicio FROM IntegrationExecutionHistory WHERE Id = @ExecutionId;
    
    UPDATE IntegrationExecutionHistory
    SET 
        FechaFin = GETDATE(),
        DuracionSegundos = DATEDIFF(SECOND, @FechaInicio, GETDATE()),
        Estado = @Estado,
        AsociadosProcesados = @AsociadosProcesados,
        ProductosProcesados = @ProductosProcesados,
        MovimientosProcesados = @MovimientosProcesados,
        TasasProcesadas = @TasasProcesadas,
        ErrorMessage = @ErrorMessage
    WHERE Id = @ExecutionId;
END
GO

PRINT '? SP sp_LogExecutionEnd creado';
GO

-- ================================================================
-- 10. VISTA DE ÚLTIMAS EJECUCIONES
-- ================================================================

IF EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_RecentExecutions]'))
    DROP VIEW [dbo].[vw_RecentExecutions];
GO

CREATE VIEW [dbo].[vw_RecentExecutions]
AS
    SELECT TOP 100
        Id,
        CONVERT(VARCHAR, FechaInicio, 120) AS FechaInicio,
        CONVERT(VARCHAR, FechaFin, 120) AS FechaFin,
        DuracionSegundos,
        Estado,
        AsociadosProcesados,
        ProductosProcesados,
        MovimientosProcesados,
        TasasProcesadas,
        CASE 
            WHEN Estado = 'Success' THEN '?'
            WHEN Estado = 'Error' THEN '?'
            WHEN Estado = 'Running' THEN '??'
            ELSE '?'
        END AS Icono,
        ErrorMessage
    FROM IntegrationExecutionHistory
    ORDER BY FechaInicio DESC;
GO

PRINT '? Vista vw_RecentExecutions creada';
GO

-- ================================================================
-- 11. VERIFICACIÓN FINAL
-- ================================================================

PRINT '';
PRINT '???????????????????????????????????????????????????????????';
PRINT '              ? INSTALACIÓN COMPLETADA';
PRINT '???????????????????????????????????????????????????????????';
PRINT '';
PRINT '?? Objetos creados:';
PRINT '   ? Tabla: IntegrationSettings';
PRINT '   ? Tabla: IntegrationExecutionHistory';
PRINT '   ? SP: sp_GetIntegrationSettings';
PRINT '   ? SP: sp_UpdateIntegrationSetting';
PRINT '   ? SP: sp_ViewCurrentConfiguration';
PRINT '   ? SP: sp_LogExecutionStart';
PRINT '   ? SP: sp_LogExecutionEnd';
PRINT '   ? Vista: vw_RecentExecutions';
PRINT '';
PRINT '?? Próximos pasos:';
PRINT '   1. Configurar appsettings.json con la conexión a esta BD';
PRINT '   2. Ejecutar: EXEC sp_ViewCurrentConfiguration';
PRINT '   3. Ajustar horarios con: EXEC sp_UpdateIntegrationSetting';
PRINT '';
PRINT '???????????????????????????????????????????????????????????';
GO

-- ================================================================
-- 12. MOSTRAR CONFIGURACIÓN ACTUAL
-- ================================================================

EXEC sp_ViewCurrentConfiguration;
GO
