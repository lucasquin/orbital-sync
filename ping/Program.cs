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

// Endpoint para receber ping e responder
app.MapPost("/ping", async (HttpContext context, IHttpClientFactory httpClientFactory) =>
{
    var httpClient = httpClientFactory.CreateClient();
    var pongUrl = Environment.GetEnvironmentVariable("PONG_API_URL") ?? "http://localhost:5001";

    try
    {
        var response = await httpClient.PostAsync($"{pongUrl}/pong",
            new StringContent(JsonSerializer.Serialize(new { message = "ping from ping-api", timestamp = DateTime.UtcNow }),
            System.Text.Encoding.UTF8, "application/json"));

        if (response.IsSuccessStatusCode)
        {
            var responseContent = await response.Content.ReadAsStringAsync();
            return Results.Ok(new
            {
                message = "Ping sent successfully",
                response = JsonSerializer.Deserialize<object>(responseContent),
                timestamp = DateTime.UtcNow
            });
        }
        else
        {
            return Results.BadRequest(new { message = "Failed to send ping", statusCode = response.StatusCode });
        }
    }
    catch (Exception ex)
    {
        return Results.BadRequest(new { message = "Error sending ping", error = ex.Message });
    }
});

app.MapGet("/start-ping", async (IHttpClientFactory httpClientFactory) =>
{
    var httpClient = httpClientFactory.CreateClient();
    var selfUrl = Environment.GetEnvironmentVariable("PING_API_URL") ?? "http://localhost:5000";

    try
    {
        var response = await httpClient.PostAsync($"{selfUrl}/ping", null);
        var responseContent = await response.Content.ReadAsStringAsync();

        return Results.Ok(new
        {
            message = "Ping initiated",
            result = JsonSerializer.Deserialize<object>(responseContent)
        });
    }
    catch (Exception ex)
    {
        return Results.BadRequest(new { message = "Error initiating ping", error = ex.Message });
    }
});

var port = Environment.GetEnvironmentVariable("PORT") ?? "5000";
app.Run($"http://0.0.0.0:{port}");
