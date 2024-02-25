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
    private readonly ILogger<TeamController> _logger;

    public TeamController(
        IHttpClientFactory httpClientFactory,
        DoorService doorService,
        GradingService gradingService,
        ILogger<TeamController> logger)
    {
        _httpClientFactory = httpClientFactory;
        _doorService = doorService;
        _gradingService = gradingService;
        _logger = logger;
    }
    
    [HttpPost]
    public async Task<IActionResult> Get([FromQuery] string request, CancellationToken ct)
    {
        string payload;
        using (var reader = new StreamReader(Request.Body, encoding: Encoding.UTF8, detectEncodingFromByteOrderMarks: false))
        {
            payload = await reader.ReadToEndAsync(ct);
        }
        
        HandleRequestPayload(request, payload);
        
        using var httpClient = _httpClientFactory.CreateClient();
        var httpRequestMessage = new HttpRequestMessage
        {
            Content = new StringContent(payload),
            Method = HttpMethod.Post,
            RequestUri = new Uri($"http://team.private.dev.cs2024.one/router?request={request}")
        };
        
        var httpResponseMessage = await httpClient.SendAsync(httpRequestMessage, ct);

        var result = await HandleResponsePayload(request, await httpResponseMessage.Content.ReadAsStringAsync(ct), httpResponseMessage.IsSuccessStatusCode, ct);
        if(!result.IsSuccess)
        {
            return NotFound(result.Description ?? "Request failed...");
        }

        var responsePayload = await httpResponseMessage.Content.ReadAsStringAsync(ct);
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
    
    private async Task<Result> HandleResponsePayload(string request, string payload, bool isSuccess, CancellationToken ct)
    {
        switch (request)
        {
            case "status":
                _gradingService.SetStatus("status", isSuccess);
                return new Result(isSuccess);
            case "map":
                return HandleMap(payload, isSuccess);
            case "weather":
                return await HandleWeather(payload, isSuccess, ct);
            default:
                return new Result(isSuccess);
        }
    }

    private async Task<Result> HandleWeather(string payload, bool isSuccess, CancellationToken ct)
    {
        await Task.CompletedTask;
        if (!isSuccess)
        {
            return new Result(false, "Request failed");
        }

        return new Result(isSuccess);
    }
    
    private Result HandleMap(string payload, bool isSuccess)
    {
        if (!isSuccess)
        {
            return new Result(false, "Request failed");
        }

        return new Result(isSuccess);
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
