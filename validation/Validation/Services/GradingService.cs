using Azure.Data.Tables;
using Validation.Classes;

namespace Validation.Services;

public class GradingService
{
    private readonly ILogger<GradingService> _logger;
    private readonly string _connectionString;
    private readonly string _tableName;
    
    public GradingService(ILogger<GradingService> logger, IConfiguration configuration)
    {
        _logger = logger;
        
        var tableStorageAccountName = configuration["TableStorageAccountName"];
        var tableStorageAccountKey = configuration["TableStorageAccountKey"];
        var teamName = configuration["TeamName"];
        
        _connectionString = $"DefaultEndpointsProtocol=https;AccountName={tableStorageAccountName};AccountKey={tableStorageAccountKey};EndpointSuffix=core.windows.net";
        _tableName = $"scores{teamName}";
    }

    public void SetStatus(string step, Result result)
    {
        var entity = StatusEntity.FromResult(step, result);
        AddEntity(entity).ConfigureAwait(false);
    }

    private async Task AddEntity(StatusEntity entity)
    {
        try
        {
            var tableClient = await GetTableClient();
            await tableClient.UpsertEntityAsync(entity, TableUpdateMode.Replace, CancellationToken.None);
        }
        catch (Exception e)
        {
            _logger.LogWarning(e, "Failed to add status for {}", entity);
            return;
        }
        
        _logger.LogInformation("Status set at {} for step {} with description {}", entity.StepName, entity.IsSuccess, entity.Description);
    }
    
    private async Task<TableClient> GetTableClient()
    {
        var serviceClient = new TableServiceClient(_connectionString);
        var tableClient = serviceClient.GetTableClient(_tableName);
        await tableClient.CreateIfNotExistsAsync();
        return tableClient;
    }
}
