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

    public async Task<Result> CheckWeather(Location location, Weather weather, CancellationToken ct)
    {
        var isValid = await ValidateWeather(location, weather, ct);
        _gradingService.SetStatus("weather", isValid);
        return isValid;
    }

    private async Task<Result> ValidateWeather(Location location, Weather weather, CancellationToken ct)
    {
        var (x, y) = location;
        var request = $"https://api.open-meteo.com/v1/forecast?latitude={x}&longitude={y}&current=temperature_2m,precipitation,wind_speed_10m";
        
        JsonNode? node;
        try
        {
            using var client = _httpClientFactory.CreateClient();
            var response = await client.GetAsync(request, ct);
            node = await JsonNode.ParseAsync(await response.Content.ReadAsStreamAsync(ct), cancellationToken: ct);

            if (node == null)
            {
                const string message = "Received payload is null";
                _logger.LogWarning(message);
                return new Result(false, message);
            }
        }
        catch (Exception e)
        {
            const string message = "Failed to fetch weather";
            _logger.LogWarning(e, message);
            return new Result(false, message);
        }

        try
        {
            var current = node["current"]!;
            var temp = (double)current["temperature_2m"]!;
            var precipitation = (double)current["precipitation"]!;
            var wind = (double)current["wind_speed_10m"]!;

            return new Result(temp - 2.5 <= weather.temperature && weather.temperature <= temp + 2.5);
        }
        catch (Exception e)
        {
            const string message = "Failed to parse payload";
            _logger.LogWarning(e, message);
            return new Result(false, message);
        }
    }
}
