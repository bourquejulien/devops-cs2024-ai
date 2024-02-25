using System.Globalization;
using System.Security.Cryptography;
using Validation.Classes;

namespace Validation.Services;

public class MapService
{
    private readonly GradingService _gradingService;
    private readonly ILogger<MapService> _logger;
    private readonly MD5 _md5;
    
    public MapService(GradingService gradingService, ILogger<MapService> logger)
    {
        _gradingService = gradingService;
        _logger = logger;
        _md5 = MD5.Create();
    }

    public Result CheckMap(Map map, MapRequest mapRequest)
    {
        Result result;
        try
        {
            result = ValidateMap(map, mapRequest);
        }
        catch (Exception)
        {
            result = new Result(false);
        }
        
        _gradingService.SetStatus("map", result);
        return result;
    }

    private Result ValidateMap(Map map, MapRequest mapRequest)
    {
        var (x, y, size) = mapRequest;
        
        var num = (long)Math.Floor((x + y) * 1e5);
        var digest = _md5.ComputeHash(System.Text.Encoding.ASCII.GetBytes(num.ToString(CultureInfo.InvariantCulture)));
        
        for (var i = 0; i < size; ++i) {
            for (var j = 0; j < size; ++j) {
                if (i == size / 2 && j == size / 2)
                {
                    if (map.map[i][j] != 0)
                    {
                        return new Result(false, $"Mismatch at ({i}, {j})");
                    }
                    
                    continue;
                }

                var index = (i + j) % (digest.Length - 1);
                var result = digest[index];

                if (map.map[i][j] != result)
                {
                    return new Result(false, $"Mismatch at ({i}, {j})");
                }
            }
        }
        
        return new Result(true);
    }
}
