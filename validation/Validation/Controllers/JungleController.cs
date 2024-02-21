using System.Text;
using System.Text.Json;
using Microsoft.AspNetCore.Mvc;
using Validation.Services;

namespace Validation.Controllers;

[ApiController]
[Route("[controller]")]
public class JungleController : Controller
{
    private readonly IHttpClientFactory _httpClientFactory;
    private readonly DoorService _doorService;

    public JungleController(IHttpClientFactory httpClientFactory, DoorService doorService)
    {
        _httpClientFactory = httpClientFactory;
        _doorService = doorService;
    }
    
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
    
    [HttpPost]
    [Route("unlock")]
    public async Task<IActionResult> Unlock([FromQuery] string password)
    {
        var result = _doorService.Get(password);
        
        using var httpClient = _httpClientFactory.CreateClient();

        var content = new StringContent(JsonSerializer.Serialize(new { isSuccess = result.IsSuccess, result = result.Description }), Encoding.UTF8, "application/json");
        var httpResponseMessage = await httpClient.PostAsync("http://jungle/unlock", content);
        
        if (!httpResponseMessage.IsSuccessStatusCode)
        {
            return NotFound("Pod not found...");
        }
        
        var httpResult = await httpResponseMessage.Content.ReadAsStringAsync();
        return Ok(httpResult);
    }
}
