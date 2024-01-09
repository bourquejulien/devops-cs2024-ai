var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHealthChecks();
builder.Services.AddHttpClient();
builder.Services.AddControllers();

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
