# ?? Autenticación con API Key

## ?? **RESUMEN**

El IntegradorOptimo ahora usa **autenticación por API Key** en lugar de JWT para comunicarse con la API de FondoSuma.

**Fecha del cambio**: Enero 2025  
**Razón**: Simplificar la autenticación y evitar la generación de tokens por cada consulta  

---

## ?? **CONFIGURACIÓN**

### **appsettings.json**

```json
{
  "ApiSettings": {
    "BaseUrl": "https://api.fodnosuma.com",
    "ApiKey": "LlaveAuthApiKey-!@#"
  }
}
```

**Importante**:
- ? Reemplaza `"LlaveAuthApiKey-!@#"` con la API Key real proporcionada por el equipo de FondoSuma
- ? Mantén este valor seguro y NO lo compartas en repositorios públicos
- ? Usa variables de entorno en producción (ver sección de Seguridad)

---

## ?? **CÓMO FUNCIONA**

### **Headers HTTP Enviados**

Cada solicitud HTTP incluye automáticamente:

```http
POST /api/integration/asociados HTTP/1.1
Host: api.fodnosuma.com
X-API-Key: LlaveAuthApiKey-!@#
Content-Type: application/json
Accept: application/json

{
  "campo1": "valor1",
  "campo2": "valor2"
}
```

### **Código en ApiClientService**

```csharp
public ApiClientService(HttpClient httpClient, IConfiguration configuration)
{
    _httpClient = httpClient;
    _baseUrl = configuration["ApiSettings:BaseUrl"];
    _apiKey = configuration["ApiSettings:ApiKey"];
    
    // Agrega X-API-Key a TODAS las solicitudes
    _httpClient.DefaultRequestHeaders.Add("X-API-Key", _apiKey);
    _httpClient.DefaultRequestHeaders.Accept.Add(
        new MediaTypeWithQualityHeaderValue("application/json")
    );
}
```

---

## ?? **ENDPOINTS DISPONIBLES**

| Endpoint | Método | Descripción | Body Example |
|----------|--------|-------------|--------------|
| `/api/integration/asociados` | POST | Sincronizar asociados | `List<AsociadoDto>` |
| `/api/integration/productos?isFullLoad=true` | POST | Sincronizar productos (full) | `List<ProductoDto>` |
| `/api/integration/productos?isFullLoad=false` | POST | Sincronizar productos (incremental) | `List<ProductoDto>` |
| `/api/integration/movimientos` | POST | Sincronizar movimientos | `List<MovimientoDto>` |
| `/api/integration/tasas` | POST | Sincronizar tasas | `List<TasaDto>` |
| `/api/integration/fecha-corte` | POST | Actualizar fecha corte | `FechaCorteDto` |

---

## ?? **PRUEBAS CON CURL**

### **1. Probar Asociados**

```bash
curl -X POST https://api.fodnosuma.com/api/integration/asociados \
  -H "X-API-Key: LlaveAuthApiKey-!@#" \
  -H "Content-Type: application/json" \
  -d '[
    {
      "numeroDocumento": "1234567890",
      "nombres": "Juan Carlos",
      "apellidos": "Pérez García",
      "email": "juan.perez@example.com",
      "celular": "3001234567",
      "fechaAfiliacion": "2024-01-15T00:00:00",
      "estado": "Activo"
    }
  ]'
```

### **2. Probar Productos (FullLoad)**

```bash
curl -X POST "https://api.fodnosuma.com/api/integration/productos?isFullLoad=true" \
  -H "X-API-Key: LlaveAuthApiKey-!@#" \
  -H "Content-Type: application/json" \
  -d '[
    {
      "numeroDocumento": "1234567890",
      "codigoProducto": "AHORRO-001",
      "nombreProducto": "Ahorro Programado",
      "saldo": 5000000.50,
      "fechaApertura": "2024-01-15T00:00:00",
      "estado": "Activo"
    }
  ]'
```

### **3. Probar Movimientos**

```bash
curl -X POST https://api.fodnosuma.com/api/integration/movimientos \
  -H "X-API-Key: LlaveAuthApiKey-!@#" \
  -H "Content-Type: application/json" \
  -d '[
    {
      "numeroDocumento": "1234567890",
      "codigoProducto": "AHORRO-001",
      "fechaMovimiento": "2024-12-01T10:30:00",
      "tipoMovimiento": "DEPOSITO",
      "valor": 100000.00,
      "descripcion": "Depósito en efectivo"
    }
  ]'
```

### **4. Probar Tasas**

```bash
curl -X POST https://api.fodnosuma.com/api/integration/tasas \
  -H "X-API-Key: LlaveAuthApiKey-!@#" \
  -H "Content-Type: application/json" \
  -d '[
    {
      "codigoTasa": "TASA-CDT-12M",
      "nombreTasa": "CDT 12 Meses",
      "valorTasa": 12.5,
      "fechaVigencia": "2024-01-01T00:00:00"
    }
  ]'
```

### **5. Probar Fecha Corte**

```bash
curl -X POST https://api.fodnosuma.com/api/integration/fecha-corte \
  -H "X-API-Key: LlaveAuthApiKey-!@#" \
  -H "Content-Type: application/json" \
  -d '{
    "fechaCorte": "2024-12-31T23:59:59"
  }'
```

---

## ?? **SEGURIDAD**

### **Variables de Entorno (RECOMENDADO para Producción)**

En lugar de poner la API Key directamente en `appsettings.json`, usa variables de entorno:

#### **Windows (PowerShell)**

```powershell
# Establecer variable de entorno para el servicio
[System.Environment]::SetEnvironmentVariable(
    "ApiSettings__ApiKey", 
    "LlaveAuthApiKey-!@#", 
    "Machine"
)

# Reiniciar el servicio
Restart-Service -Name IntegradorOptimo
```

#### **appsettings.json (en producción)**

```json
{
  "ApiSettings": {
    "BaseUrl": "https://api.fodnosuma.com",
    "ApiKey": "${ApiSettings__ApiKey}"
  }
}
```

O simplemente déjalo vacío y el sistema leerá de la variable de entorno automáticamente:

```json
{
  "ApiSettings": {
    "BaseUrl": "https://api.fodnosuma.com"
  }
}
```

```powershell
# La API Key se lee de la variable de entorno ApiSettings__ApiKey
```

---

## ?? **RESPUESTAS DE ERROR**

### **401 Unauthorized**

```json
{
  "error": "Invalid API Key"
}
```

**Causas**:
- ? API Key incorrecta en `appsettings.json`
- ? API Key expirada (solicitar nueva al equipo de FondoSuma)
- ? Header `X-API-Key` no enviado

**Solución**:
```powershell
# 1. Verificar la API Key en la configuración
notepad C:\IntegradorOptimo\appsettings.json

# 2. Reiniciar el servicio
Restart-Service -Name IntegradorOptimo

# 3. Ver logs
Get-Content C:\Logs\IntegradorOptimo\log-*.txt -Tail 50
```

### **403 Forbidden**

```json
{
  "error": "Access denied"
}
```

**Causas**:
- ? API Key válida pero sin permisos para ese endpoint
- ? IP no autorizada

**Solución**: Contactar al equipo de FondoSuma

### **500 Internal Server Error**

```json
{
  "error": "Internal server error"
}
```

**Causas**:
- ? Error en el servidor de la API
- ? Datos inválidos en el body

**Solución**: Revisar logs del IntegradorOptimo y contactar soporte

---

## ?? **LOGS**

### **Ejemplo de Log Exitoso**

```log
2025-01-05 02:00:15.123 [INF] ?? Sincronizando Asociados...
2025-01-05 02:00:15.456 [INF]    Total asociados obtenidos: 8,543
2025-01-05 02:00:16.123 [INF]    ? Batch 1/18: 500 registros en 345ms
2025-01-05 02:00:16.789 [INF]    ? Batch 2/18: 500 registros en 322ms
...
2025-01-05 02:00:28.456 [INF]    ? Asociados completados en 13.3s
```

### **Ejemplo de Log con Error 401**

```log
2025-01-05 02:00:15.123 [INF] ?? Sincronizando Asociados...
2025-01-05 02:00:15.456 [ERR] ? Error sincronizando Asociados
System.Net.Http.HttpRequestException: Response status code does not indicate success: 401 (Unauthorized).
   at ApiClientService.SendDataAsync[T](String url, T data, CancellationToken ct)
```

**Solución**: Verificar API Key en `appsettings.json`

---

## ?? **MIGRACIÓN DESDE JWT**

### **Cambios Realizados**

| Antes (JWT) | Después (API Key) |
|-------------|-------------------|
| `"JwtToken": "eyJhbGc..."` | `"ApiKey": "LlaveAuthApiKey-!@#"` |
| `Authorization: Bearer {token}` | `X-API-Key: {key}` |
| Token expira (necesita renovar) | Key permanente (sin expiración) |
| Autenticación compleja | Autenticación simple |

### **Ventajas de API Key**

? **Más simple**: No requiere gestión de tokens  
? **Sin expiración**: No necesita renovación periódica  
? **Mejor performance**: No hay overhead de validación de JWT  
? **Más eficiente**: Una key por aplicación, no por cada request  

---

## ??? **TROUBLESHOOTING**

### **Problema: La API retorna 401**

```powershell
# 1. Verificar la configuración
Get-Content C:\IntegradorOptimo\appsettings.json | Select-String "ApiKey"

# 2. Probar con curl
curl -X POST https://api.fodnosuma.com/api/integration/fecha-corte `
  -H "X-API-Key: TU_API_KEY_REAL" `
  -H "Content-Type: application/json" `
  -d '{"fechaCorte":"2024-12-31T23:59:59"}'

# 3. Si curl funciona pero el servicio no, reiniciar
Restart-Service -Name IntegradorOptimo
```

### **Problema: Headers no se envían**

Verificar que el código tenga:

```csharp
_httpClient.DefaultRequestHeaders.Add("X-API-Key", _apiKey);
```

### **Problema: API Key en logs**

Si ves la API Key en los logs (problema de seguridad), configúrala como variable de entorno.

---

## ?? **REFERENCIAS**

- **Configuración**: `src/Integrador.Worker/appsettings.json`
- **Implementación**: `src/Integrador.Worker/Services/ApiClientService.cs`
- **Documentación API**: Solicitar al equipo de FondoSuma
- **Soporte**: Contactar al administrador de la API

---

## ? **CHECKLIST DE CONFIGURACIÓN**

Antes de ejecutar en producción:

- [ ] API Key configurada en `appsettings.json`
- [ ] API Key válida (probada con curl)
- [ ] BaseUrl correcto (`https://api.fodnosuma.com`)
- [ ] Todos los endpoints probados individualmente
- [ ] Servicio reiniciado después de cambios
- [ ] Logs verificados sin errores 401/403
- [ ] API Key guardada de forma segura (variable de entorno en prod)

---

**Versión del Documento**: 1.0  
**Última Actualización**: Enero 2025  
**Tipo de Autenticación**: API Key (X-API-Key header)  
**Estado**: ? Implementado y funcional  

?? **¡Autenticación simplificada y lista para usar!** ??
