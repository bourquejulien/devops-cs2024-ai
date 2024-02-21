using System.Text;
using Microsoft.AspNetCore.Mvc;

namespace Validation.Controllers;

[ApiController]
[Route("[controller]")]
public class TeamController : Controller
{
    private readonly IHttpClientFactory _httpClientFactory;

    public TeamController(IHttpClientFactory httpClientFactory) => _httpClientFactory = httpClientFactory;
    
    [HttpPost]
    public async Task<IActionResult> Get([FromQuery] string request, CancellationToken ct)
    {
        StringContent stringContent;
        using (var reader = new StreamReader(Request.Body, encoding: Encoding.UTF8, detectEncodingFromByteOrderMarks: false))
        {
            stringContent = new StringContent(await reader.ReadToEndAsync(ct));
        }
        
        using var httpClient = _httpClientFactory.CreateClient();
        
        var httpRequestMessage = new HttpRequestMessage
        {
            Content = stringContent,
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
}