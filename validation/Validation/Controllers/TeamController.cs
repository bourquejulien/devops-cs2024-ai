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
    private readonly ILogger<TeamController> _logger;

    public TeamController(IHttpClientFactory httpClientFactory, DoorService doorService, ILogger<TeamController> logger)
    {
        _httpClientFactory = httpClientFactory;
        _doorService = doorService;
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
        
        HandlePayload(request, payload);
        
        using var httpClient = _httpClientFactory.CreateClient();
        
        var httpRequestMessage = new HttpRequestMessage
        {
            Content = new StringContent(payload),
            Method = HttpMethod.Post,
            RequestUri = new Uri($"http://team.private.dev.cs2024.one/router?request={request}")
        };
        
        var httpResponseMessage = await httpClient.SendAsync(httpRequestMessage, ct);

        if (!httpResponseMessage.IsSuccessStatusCode)
        {
            return NotFound("Pod service not found...");
        }

        var result = await httpResponseMessage.Content.ReadAsStringAsync(ct);
        return Ok(result);
    }

    private void HandlePayload(string request, string payload)
    {
        switch (request)
        {
            case "door":
                HandleDoor(payload);
                break;
            default:
                break;
        }
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
            _logger.LogWarning("Failed to parse door payload");
            throw;
        }

        if (doorRequest == null)
        {
            return;
        }
        
        _doorService.Add(doorRequest.hash);
    }
}
