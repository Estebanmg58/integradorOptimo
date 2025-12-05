# ?? Solución: "Unable to start program" en Visual Studio

## ? **PROBLEMA**

Visual Studio muestra el error:
```
Unable to start program. The startup project cannot be launched.
Ensure that the correct project is set as the startup project.
```

## ? **SOLUCIÓN RÁPIDA (3 pasos)**

### **Paso 1: Localiza el proyecto en Solution Explorer**

En el panel derecho de Visual Studio (Solution Explorer), busca:

```
Solution 'Integrador' (3 of 3 projects)
??? Integrador.Core
??? Integrador.Infrastructure
??? Integrador.Worker  ? ESTE ES EL QUE NECESITAS
```

### **Paso 2: Clic derecho sobre Integrador.Worker**

Haz **clic derecho** sobre el proyecto `Integrador.Worker` y selecciona:

```
Set as Startup Project
```

### **Paso 3: Verificar y ejecutar**

Después de hacer esto:

1. El proyecto `Integrador.Worker` aparecerá en **NEGRITA** en el Solution Explorer
2. Arriba, el botón verde dirá: **? Integrador.Worker**
3. Ahora puedes presionar **F5** para ejecutar con debugger

---

## ?? **RESULTADO ESPERADO**

Después de configurar el Startup Project:

**ANTES:**
```
Integrador.Core
Integrador.Infrastructure
Integrador.Worker
```

**DESPUÉS:**
```
Integrador.Core
Integrador.Infrastructure
Integrador.Worker  ? EN NEGRITA
```

Y el botón de ejecución cambiará a:
```
[Debug ?]  [Any CPU ?]  [? Integrador.Worker]
```

---

## ?? **PARA USAR BREAKPOINTS**

Una vez configurado correctamente:

1. **Pon tus breakpoints** (clic en el margen izquierdo del código)
2. **Presiona F5** (o click en el botón verde)
3. El programa se **detendrá** en tus breakpoints

### **Ejemplo de breakpoint activo:**

```csharp
public async Task SendProductosAsync(List<ProductoDto> productos, bool isFullLoad, CancellationToken ct)
{
?   var url = $"{_baseUrl}/api/integration/productos?isFullLoad={isFullLoad}";  // ? BREAKPOINT AQUÍ
    await SendDataAsync(url, productos, ct);
}
```

El círculo rojo (?) indica un breakpoint activo.

---

## ?? **EJECUCIÓN INMEDIATA (Para pruebas)**

Si quieres que el servicio se ejecute INMEDIATAMENTE sin esperar el cron:

### **Opción A: Cambiar el cron temporalmente**

```sql
-- En SQL Server
EXEC sp_UpdateIntegrationSetting 'ScheduleCron', '*/1 * * * *';
-- Ejecutará cada 1 minuto
```

### **Opción B: Modificar el código temporalmente**

En `IntegrationWorker.cs`, agrega al inicio de `ExecuteAsync`:

```csharp
protected override async Task ExecuteAsync(CancellationToken stoppingToken)
{
    _logger.LogInformation("?? Integrador Óptimo iniciado");

    // ?? TEMPORAL PARA DEBUGGING - Ejecutar inmediatamente
    await RunIntegrationAsync(stoppingToken);
    
    // Continuar con el cron normal
    while (!stoppingToken.IsCancellationRequested)
    {
        // ... resto del código
    }
}
```

Esto ejecutará la sincronización INMEDIATAMENTE al presionar F5.

---

## ?? **ALTERNATIVA: Ejecutar sin Visual Studio**

Si solo quieres ejecutar sin debugger:

```powershell
cd C:\Users\esteb\Source\Repos\integradorOptimo\src\Integrador.Worker
dotnet run
```

**Nota**: Los breakpoints NO funcionarán con este método.

---

## ?? **VERIFICAR QUE FUNCIONA**

Cuando presiones F5 con el proyecto configurado correctamente, deberías ver en la consola:

```
2025-01-05 10:30:15.123 [INF] ?? Integrador Óptimo iniciado - Servicio de Windows activo
2025-01-05 10:30:15.456 [INF] ? Próxima ejecución programada: 2025-01-06 02:00:00
```

Y si configuraste para ejecución inmediata:

```
2025-01-05 10:30:15.123 [INF] ?? Integrador Óptimo iniciado
2025-01-05 10:30:15.456 [INF] ========================================
2025-01-05 10:30:15.456 [INF] ?? INICIANDO SINCRONIZACIÓN COMPLETA
2025-01-05 10:30:15.456 [INF] ========================================
2025-01-05 10:30:15.789 [INF] ?? Sincronizando Asociados...
```

Aquí es donde tu breakpoint se activará. ?

---

## ?? **SI SIGUE SIN FUNCIONAR**

### **Problema: Breakpoint aparece vacío (círculo rojo hueco)**

**Causa**: El código no se compiló con símbolos de debug.

**Solución**:
1. Asegúrate de estar en modo **Debug** (no Release)
2. Limpia y recompila:
   ```powershell
   dotnet clean
   dotnet build -c Debug
   ```
3. Cierra y vuelve a abrir Visual Studio
4. Presiona F5

### **Problema: El servicio no se detiene**

**Causa**: Puede haber otro proceso ejecutándose.

**Solución**:
```powershell
Get-Process -Name "Integrador.Worker" -ErrorAction SilentlyContinue | Stop-Process -Force
```

---

## ? **RESUMEN**

| Paso | Acción |
|------|--------|
| 1 | Clic derecho en `Integrador.Worker` |
| 2 | Seleccionar "Set as Startup Project" |
| 3 | Verificar que aparece en **negrita** |
| 4 | Poner breakpoints en el código |
| 5 | Presionar **F5** |
| 6 | El debugger se detiene en breakpoints ? |

---

**¡Listo para debuggear!** ????
