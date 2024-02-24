using Validation.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHealthChecks();
builder.Services.AddHttpClient();
builder.Services.AddControllers();
builder.Services.AddSingleton<GradingService>();
builder.Services.AddSingleton<WeatherService>();
builder.Services.AddSingleton<DoorService>();
builder.Services.AddSingleton<MapService>();
builder.Services.AddHostedService<DoorService>(provider => provider.GetService<DoorService>()!);

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapHealthChecks("/healthz");
app.UseHttpsRedirection();
app.UsePathBase(app.Configuration["BasePath"]);
app.MapControllers();

app.MapGet("/status", () => "ok")
    .WithName("GetStatus")
    .WithOpenApi();

app.Run();
