namespace Validation.Services;

public class GradingService
{
    private readonly ILogger<GradingService> _logger;
    
    public GradingService(ILogger<GradingService> logger)
    {
        _logger = logger;
    }

    public void SetStatus(string step, bool isSuccess, string? description = null)
    {
        _logger.LogInformation("Status set at {} for step {} with description {}", step, isSuccess, description);
    }
}
