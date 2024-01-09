using Microsoft.AspNetCore.Mvc;

namespace Validation.Controllers;

[ApiController]
[Route("[controller]")]
public class JungleController : Controller
{
    private readonly IHttpClientFactory _httpClientFactory;

    public JungleController(IHttpClientFactory httpClientFactory) => _httpClientFactory = httpClientFactory;
    
    [HttpGet]
    public async Task<IActionResult> Get()
    {
        using var httpClient = _httpClientFactory.CreateClient();
        var httpResponseMessage = await httpClient.GetAsync("http://jungle/status");

        if (!httpResponseMessage.IsSuccessStatusCode)
        {
            return NotFound("Pod not found...");
        }

        var result = await httpResponseMessage.Content.ReadAsStringAsync();
        return Ok(result);
    }
}
