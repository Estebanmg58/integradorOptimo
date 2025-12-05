using Polly;
using Polly.Extensions.Http;

namespace Integrador.Worker.Services;

public static class PollyPolicies
{
    public static IAsyncPolicy<HttpResponseMessage> GetRetryPolicy()
    {
        return HttpPolicyExtensions
            .HandleTransientHttpError()
            .WaitAndRetryAsync(
                3,
                retryAttempt => TimeSpan.FromSeconds(Math.Pow(2, retryAttempt)),
                onRetry: (outcome, timespan, retryCount, context) =>
                {
                    Console.WriteLine($"?? Reintento {retryCount} después de {timespan.TotalSeconds}s debido a: {outcome.Exception?.Message ?? outcome.Result.StatusCode.ToString()}");
                });
    }

    public static IAsyncPolicy<HttpResponseMessage> GetCircuitBreakerPolicy()
    {
        return HttpPolicyExtensions
            .HandleTransientHttpError()
            .CircuitBreakerAsync(
                5,
                TimeSpan.FromSeconds(30),
                onBreak: (outcome, duration) =>
                {
                    Console.WriteLine($"?? Circuit Breaker ABIERTO por {duration.TotalSeconds}s debido a: {outcome.Exception?.Message ?? outcome.Result.StatusCode.ToString()}");
                },
                onReset: () =>
                {
                    Console.WriteLine("?? Circuit Breaker CERRADO - Conexión restablecida");
                },
                onHalfOpen: () =>
                {
                    Console.WriteLine("?? Circuit Breaker SEMI-ABIERTO - Probando conexión...");
                });
    }
}
