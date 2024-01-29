using Microsoft.AspNetCore.Mvc;

namespace Validation.Controllers;

[ApiController]
[Route("[controller]")]
public class TeamController : Controller
{
    private readonly IHttpClientFactory _httpClientFactory;

    public TeamController(IHttpClientFactory httpClientFactory) => _httpClientFactory = httpClientFactory;
    
    [HttpGet]
    public async Task<IActionResult> Get([FromQuery] string request, [FromQuery] string address, CancellationToken ct)
    {
        using var httpClient = _httpClientFactory.CreateClient();
        
        var httpRequestMessage = new HttpRequestMessage
        {
            Method = HttpMethod.Get,
            RequestUri = new Uri($"http://team.private.dev.cs2024.one/router?request={request}&address={address}"),
        };
        
        var httpResponseMessage = await httpClient.SendAsync(httpRequestMessage, ct);

        if (!httpResponseMessage.IsSuccessStatusCode)
        {
            return NotFound("Pod service not found...");
        }

        var result = await httpResponseMessage.Content.ReadAsStringAsync(ct);
        return Ok(result);
    }
}