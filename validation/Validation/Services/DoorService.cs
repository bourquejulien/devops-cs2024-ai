using System.Collections.Concurrent;
using Validation.Classes;

namespace Validation.Services;

record History(string hash, string Password, DateTime Time);

public class DoorService : IHostedService
{
    private readonly ILogger<DoorService> _logger;
    private Dictionary<string, string> _passwords;
    private ConcurrentDictionary<string, History> _history;
    
    public DoorService(ILogger<DoorService> logger)
    {
        _logger = logger;
        _passwords = new Dictionary<string, string>();
        _history = new ConcurrentDictionary<string, History>();
    }

    public void Add(string hash)
    {
        if (!_passwords.TryGetValue(hash, out var password))
        {
            return;
        }
        
        _history[password] = new History(hash, password, DateTime.UtcNow);
    }

    public Result Get(string password)
    {
        if (!_history.TryGetValue(password, out var history))
        {
            return new Result(false, "Bad HASH");
        }

        if (history.Time < (DateTime.UtcNow - TimeSpan.FromMilliseconds(2)))
        {
            return new Result(false, "Too slow");
        }
        
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

        foreach (var (hash, password) in passwordsHashed.Zip(passwords))
        {
            _passwords.Add(hash, password);
        }
    }
}
