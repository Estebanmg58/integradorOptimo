# Configuración de Horario Laboral del Worker

## ?? Cambios Implementados

### ? Nuevo Horario de Ejecución
- **Horario:** 8:00 AM - 4:00 PM
- **Frecuencia:** Cada hora en punto
- **Ejecuciones diarias:** 9 ejecuciones
  - 8:00 AM
  - 9:00 AM
  - 10:00 AM
  - 11:00 AM
  - 12:00 PM
  - 1:00 PM
  - 2:00 PM
  - 3:00 PM
  - 4:00 PM

### ?? Modificaciones Realizadas

#### 1. **IntegrationWorker.cs**
Se agregó validación de horario laboral:
```csharp
private bool IsWithinBusinessHours(DateTime currentTime)
{
    var hour = currentTime.Hour;
    // Horario laboral: 8 AM (08:00) hasta 4 PM (16:00)
    return hour >= 8 && hour <= 16;
}
```

El worker ahora valida si está dentro del horario laboral antes de ejecutar:
- ? **Dentro del horario:** Ejecuta la sincronización completa
- ? **Fuera del horario:** Espera sin ejecutar, registra en el log

#### 2. **Expresión CRON**
Ejecutar el script `SQL_UPDATE_SCHEDULE.sql` para actualizar la base de datos:
```sql
UPDATE IntegrationSettings
SET ScheduleCron = '0 8-16 * * *'
WHERE Id = 1;
```

### ?? Explicación CRON: `0 8-16 * * *`
- `0` ? Minuto 0 (en punto)
- `8-16` ? Horas de 8 AM a 4 PM
- `*` ? Todos los días del mes
- `*` ? Todos los meses
- `*` ? Todos los días de la semana

## ?? Pasos para Activar

### 1. Actualizar la Base de Datos
```bash
# Conectarse a SQL Server y ejecutar:
sqlcmd -S FMSRV-FONDOSUMA -d dbIntegra -i SQL_UPDATE_SCHEDULE.sql
```

### 2. Reiniciar el Servicio Windows
```powershell
# Detener el servicio
net stop "Integrador Optimo"

# Iniciar el servicio
net start "Integrador Optimo"
```

### 3. Verificar los Logs
El worker mostrará en los logs:
```
?? Integrador Óptimo iniciado - Servicio de Windows activo
?? Horario laboral configurado: 8:00 AM - 4:00 PM (Ejecución cada hora)
?? Próxima ejecución programada: 2025-01-20 09:00:00
```

Cuando esté fuera de horario:
```
? Fuera de horario laboral. Esperando próxima ejecución...
```

## ?? Configuración Flexible

Si necesitas cambiar el horario en el futuro, solo modifica el método `IsWithinBusinessHours`:

```csharp
// Ejemplo: 7 AM - 6 PM
return hour >= 7 && hour <= 18;

// Ejemplo: Solo horario de mañana (8 AM - 12 PM)
return hour >= 8 && hour <= 12;
```

## ?? Impacto Operativo

### Antes:
- Podía ejecutarse en cualquier momento según configuración CRON
- Sin restricción de horario

### Ahora:
- 9 ejecuciones diarias garantizadas
- Solo durante horario laboral (8 AM - 4 PM)
- Más predecible y controlado
- Reduce carga fuera de horario laboral

## ?? Monitoreo

### Verificar Estado del Servicio
```powershell
Get-Service "Integrador Optimo"
```

### Ver Últimos Logs
```powershell
Get-Content "C:\IntegradorOptimo\Logs\log-*.txt" -Tail 50
```

### Verificar Próxima Ejecución
Buscar en el log la línea:
```
?? Próxima ejecución programada: [fecha y hora]
```

## ?? Notas Importantes

1. **Primera Ejecución:** Si el servicio se inicia fuera del horario laboral, esperará hasta las 8:00 AM del siguiente día
2. **Última Ejecución:** La última ejecución del día será a las 4:00 PM
3. **Fines de Semana:** El worker seguirá ejecutándose los fines de semana en el mismo horario
4. **Mantenimiento:** Si necesitas ejecutar manualmente fuera de horario, puedes desactivar temporalmente la validación

## ??? Troubleshooting

### El worker no ejecuta durante el horario
1. Verificar que el servicio esté corriendo
2. Revisar los logs para ver mensajes de error
3. Verificar la expresión CRON en la base de datos
4. Confirmar que la hora del servidor es correcta

### Cambiar horario temporalmente
Modificar directamente en la base de datos:
```sql
-- Ejecutar todo el día cada hora
UPDATE IntegrationSettings SET ScheduleCron = '0 * * * *' WHERE Id = 1;

-- Volver al horario laboral
UPDATE IntegrationSettings SET ScheduleCron = '0 8-16 * * *' WHERE Id = 1;
```

## ?? Soporte
Para cualquier consulta o ajuste adicional, contactar al equipo de desarrollo.
