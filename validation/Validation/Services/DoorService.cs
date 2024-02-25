using System.Collections.Concurrent;
using Validation.Classes;

namespace Validation.Services;

record History(string Hash, string Password, DateTime Time);

public class DoorService : IHostedService
{
    private readonly ILogger<DoorService> _logger;
    private readonly GradingService _gradingService;
    private Dictionary<string, string> _passwords;
    private ConcurrentDictionary<string, History> _history;
    
    public DoorService(ILogger<DoorService> logger, GradingService gradingService)
    {
        _logger = logger;
        _gradingService = gradingService;
        _passwords = new Dictionary<string, string>();
        _history = new ConcurrentDictionary<string, History>();
    }

    public void Add(string hash)
    {
        if (!_passwords.TryGetValue(hash, out var password))
        {
            _logger.LogWarning("Failed to find hash: {}", hash);
            return;
        }
        
        _history[password] = new History(hash, password, DateTime.UtcNow);
        _logger.LogInformation("Added hash {} with password {}", hash, password);
    }

    public Result Get(string password)
    {
        if (!_history.TryGetValue(password, out var history))
        {
            _logger.LogInformation("Cannot find password: {}", password);
            var result = new Result(false, "Bad hash");
            _gradingService.SetStatus("door", result);
            return result;
        }

        _history.Remove(password, out _);

        var duration = DateTime.UtcNow - history.Time;
        if (duration > TimeSpan.FromMilliseconds(500))
        {
            var result = new Result(false, $"Too slow, took {duration.TotalMilliseconds}ms");
            _gradingService.SetStatus("door", result);
            return result;
        }

        _gradingService.SetStatus("door", new Result(true));
        
        return new Result(true, "Good job!");
    }

    public async Task StartAsync(CancellationToken cancellationToken)
    {
        await LoadPasswords(cancellationToken);
    }

    public Task StopAsync(CancellationToken cancellationToken)
    {
        return Task.CompletedTask;
    }
    
    async private Task LoadPasswords(CancellationToken ct)
    {
        const string PASSWORD_PATH = "passwords.txt";
        const string HASH_PATH = "passwords_hashed.txt";

        var passwordsHashed = await File.ReadAllLinesAsync(PASSWORD_PATH, ct);
        var passwords = await File.ReadAllLinesAsync(HASH_PATH, ct);

        foreach (var (password, hash) in passwordsHashed.Zip(passwords))
        {
            _passwords.Add(hash, password);
        }
    }
}
