using System.Text;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Validation.Classes;
using Validation.Services;

namespace Validation.Controllers;

[ApiController]
[Route("[controller]")]
public class TeamController : Controller
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly DoorService _doorService;
    private readonly GradingService _gradingService;
    private readonly MapService _mapService;
    private readonly WeatherService _weatherService;
    private readonly ILogger<TeamController> _logger;

    public TeamController(
        IHttpClientFactory httpClientFactory,
        DoorService doorService,
        MapService mapService,
        WeatherService weatherService,
        GradingService gradingService,
        ILogger<TeamController> logger)
    {
        _httpClientFactory = httpClientFactory;
        _doorService = doorService;
        _gradingService = gradingService;
        _mapService = mapService;
        _weatherService = weatherService;
        _logger = logger;
    }
    
    [HttpPost]
    public async Task<IActionResult> Get([FromQuery] string request, CancellationToken ct)
    {
        string requestPayload;
        using (var reader = new StreamReader(Request.Body, encoding: Encoding.UTF8, detectEncodingFromByteOrderMarks: false))
        {
            requestPayload = await reader.ReadToEndAsync(ct);
        }
        
        HandleRequestPayload(request, requestPayload);
        
        using var httpClient = _httpClientFactory.CreateClient();
        var httpRequestMessage = new HttpRequestMessage
        {
            Content = new StringContent(requestPayload),
            Method = HttpMethod.Post,
            RequestUri = new Uri($"http://team.private.dev.cs2024.one/router?request={request}")
        };
        
        var httpResponseMessage = await httpClient.SendAsync(httpRequestMessage, ct);
        var responsePayload = await httpResponseMessage.Content.ReadAsStringAsync(ct);

        var result = await HandleResponsePayload(request, requestPayload, responsePayload, httpResponseMessage.IsSuccessStatusCode, ct);
        if(!result.IsSuccess)
        {
            return NotFound(result.Description ?? "Request failed...");
        }

        return Ok(responsePayload);
    }

    private void HandleRequestPayload(string request, string payload)
    {
        switch (request)
        {
            case "door":
                HandleDoor(payload);
                break;
            default:
                return;
        }
    }
    
    private async Task<Result> HandleResponsePayload(string request, string requestPayload, string responsePayload, bool isSuccess, CancellationToken ct)
    {
        switch (request)
        {
            case "status":
                _gradingService.SetStatus("status", new Result(isSuccess));
                return new Result(isSuccess);
            case "map":
                return HandleMap(requestPayload, responsePayload, isSuccess);
            case "weather":
                return await HandleWeather(requestPayload, responsePayload, isSuccess, ct);
            default:
                return new Result(isSuccess);
        }
    }

    private async Task<Result> HandleWeather(string requestPayload, string responsePayload, bool isSuccess, CancellationToken ct)
    {
        Location location;
        Weather weather;
        
        try
        {
            location = JsonSerializer.Deserialize<Location>(requestPayload)!;
        }
        catch (Exception)
        {
            _logger.LogWarning("Failed to parse location payload.");
            return new Result(false);
        }

        try
        {
            weather = JsonSerializer.Deserialize<Weather>(responsePayload)!;
        }
        catch (Exception)
        {
            return new Result(false, "Invalid payload");
        }
        
        if (!isSuccess)
        {
            return new Result(false, "Request failed");
        }

        return await _weatherService.CheckWeather(location, weather, ct);
    }
    
    private Result HandleMap(string requestPayload, string responsePayload, bool isSuccess)
    {
        MapRequest mapRequest;
        Map map;
        
        try
        {
            mapRequest = JsonSerializer.Deserialize<MapRequest>(requestPayload)!;
        }
        catch (Exception)
        {
            _logger.LogWarning("Failed to parse MapRequest payload.");
            return new Result(false);
        }

        try
        {
            map = JsonSerializer.Deserialize<Map>(responsePayload)!;
        }
        catch (Exception)
        {
            return new Result(false, "Invalid payload");
        }
        
        return !isSuccess ? new Result(false, "Request failed") : _mapService.CheckMap(map, mapRequest);
    }

    private void HandleDoor(string payload)
    {
        DoorRequest? doorRequest;
        try
        {
            doorRequest = JsonSerializer.Deserialize<DoorRequest>(payload);
        }
        catch (Exception e)
        {
            _logger.LogWarning(e, "Failed to parse door payload");
            throw;
        }

        if (doorRequest == null)
        {
            return;
        }
        
        _doorService.Add(doorRequest.hash);
    }
}
