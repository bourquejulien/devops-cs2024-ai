using System.Globalization;
using Azure;
using Azure.Data.Tables;

namespace Validation.Classes;

public class StatusEntity : ITableEntity
{
    public string PartitionKey
    {
        get => StepName;
        set => StepName = value;
    }

    public required string RowKey {get; set; }
    public DateTimeOffset? Timestamp { get; set; }
    public ETag ETag { get; set; }

    public required string StepName { get; set; }
    public required bool IsSuccess { get; set; }
    public string? Description { get; set; }

    public override string ToString()
    {
        return $"StepName: {StepName}, IsSuccess: {IsSuccess}, Description: {Description ?? "None"}";
    }

    public static StatusEntity FromResult(string stepName, Result result)
    {
        var now = DateTimeOffset.UtcNow;
        
        return new StatusEntity
        {
            RowKey = GetRowKey(now.DateTime),
            Timestamp = now,
            StepName = stepName,
            IsSuccess = result.IsSuccess,
            Description = result.Description,
        };
    }

    private static string GetRowKey(DateTime dateTime)
    {
        return $"{dateTime.Month}{dateTime.Day}{dateTime.Hour}{dateTime.Minute}";
    }
}
