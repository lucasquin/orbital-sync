using Microsoft.AspNetCore.Mvc;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddHttpClient();
builder.Services.AddHealthChecks();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.MapHealthChecks("/health");

// Endpoint para receber pong
app.MapPost("/pong", async (HttpContext context) =>
{
    string requestBody = "";
    try
    {
        using var reader = new StreamReader(context.Request.Body);
        requestBody = await reader.ReadToEndAsync();

        var pingData = string.IsNullOrEmpty(requestBody) ?
            new { message = "empty ping", timestamp = DateTime.UtcNow } :
            JsonSerializer.Deserialize<object>(requestBody);

        Console.WriteLine($"Received ping: {requestBody}");

        return Results.Ok(new
        {
            message = "Pong! Received your ping",
            receivedData = pingData,
            responseTimestamp = DateTime.UtcNow,
            from = "pong-api"
        });
    }
    catch (Exception ex)
    {
        return Results.BadRequest(new
        {
            message = "Error processing ping",
            error = ex.Message,
            receivedBody = requestBody
        });
    }
});

var port = Environment.GetEnvironmentVariable("PORT") ?? "5001";

app.Run($"http://0.0.0.0:{port}");
