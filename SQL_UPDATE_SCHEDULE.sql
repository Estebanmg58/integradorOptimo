-- ============================================
-- Actualizar Schedule CRON para ejecución combinada
-- 1 vez a las 2:00 AM + Cada hora de 8:00 AM a 8:00 PM
-- ============================================

USE dbIntegra;
GO

-- Actualizar la configuración de integración
-- CRON Expression: "0 2,8-20 * * *" significa:
-- - Minuto 0 (en punto)
-- - Hora 2 AM Y horas 8 a 20 (8 AM a 8 PM)
-- - Todos los días del mes
-- - Todos los meses
-- - Todos los días de la semana

UPDATE IntegrationSettings
SET ScheduleCron = '0 2,8-20 * * *'
WHERE Id = 1;
GO

-- Verificar el cambio
SELECT 
    Id,
    ScheduleCron,
    BatchSize,
    EnableAsociados,
    EnableProductos,
    EnableMovimientos,
    EnableTasas,
    EnableFechaCorte,
    DailyTruncateHour
FROM IntegrationSettings
WHERE Id = 1;
GO

-- ============================================
-- NOTAS IMPORTANTES:
-- ============================================
-- 1. El worker ejecutará 1 VEZ a las 2:00 AM + CADA HORA de 8 AM a 8 PM
-- 2. Horario de ejecución: 02:00, 08:00, 09:00, 10:00, 11:00, 12:00, 13:00, 14:00, 15:00, 16:00, 17:00, 18:00, 19:00, 20:00
-- 3. Total de 14 ejecuciones por día (1 nocturna + 13 durante el día)
-- 4. Fuera de este horario, el worker solo esperará sin ejecutar
-- ============================================
