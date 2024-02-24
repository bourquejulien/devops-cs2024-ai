using System.Text.Json.Nodes;
using Validation.Classes;

namespace Validation.Services;

public class WeatherService
{
    private readonly GradingService _gradingService;
    private readonly ILogger<WeatherService> _logger;
    private readonly IHttpClientFactory _httpClientFactory;
    
    public WeatherService(GradingService gradingService, ILogger<WeatherService> logger, IHttpClientFactory httpHttpClientFactory)
    {
        _gradingService = gradingService;
        _logger = logger;
        _httpClientFactory = httpHttpClientFactory;
    }

    public async Task<bool> CheckWeather(Weather weather, CancellationToken ct)
    {
        var isValid = await ValidateWeather(weather, ct);
        _gradingService.SetStatus("weather", isValid);
        return isValid;
    }

    private async Task<bool> ValidateWeather(Weather weather, CancellationToken ct)
    {
        const string request = "https://api.open-meteo.com/v1/forecast?latitude=48.41882619003699&longitude=-71.05366624859137&current=temperature_2m,precipitation,wind_speed_10m";

        using var client = _httpClientFactory.CreateClient();

        JsonNode? node;
        
        try
        {
            var response = await client.GetAsync(request, ct);
            node = await JsonNode.ParseAsync(await response.Content.ReadAsStreamAsync(ct), cancellationToken: ct);

            if (node == null)
            {
                _logger.LogWarning("Received payload is null");
                return false;
            }
        }
        catch (Exception e)
        {
            _logger.LogWarning(e, "Failed to fetch weather");
            return false;
        }

        try
        {
            var current = node["current"]!;
            var temp = (double)current["temperature"]!;
            var precipitation = (double)current["precipitation"]!;
            var wind = (double)current["windSpeed"]!;

            return temp - 2.5 <= weather.temperature && weather.temperature <= temp + 2.5;
        }
        catch (Exception e)
        {
            _logger.LogWarning(e, "Failed to parse payload");
            return false;
        }
    }
}
