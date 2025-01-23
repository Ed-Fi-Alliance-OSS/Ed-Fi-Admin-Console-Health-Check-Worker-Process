var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
// Learn more about configuring OpenAPI at https://aka.ms/aspnet/openapi
builder.Services.AddOpenApi();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();

app.MapGet(
        "/adminconsole/instances", async (HttpContext context) =>
        {
            // Accessing the HttpContext
            var request = context.Request;
            var response = context.Response;

            // Reading the request body
            using var reader = new StreamReader(request.Body);
            var requestBody = await reader.ReadToEndAsync();

            // Processing the request body (e.g., logging or parsing JSON)
            Console.WriteLine($"Received data: {requestBody}");

            return Results.Ok(new[]
            {
                new Instance(1, "tenant1", 1, 1, "instance 1", "https://api.ed-fi.org:443/v7.1/api/data/v3", "https://api.ed-fi.org/v7.1/api/oauth/token", "RvcohKz9zHI4", "E1iEFusaNf81xzCxwHfbolkC", "Completed"),
                new Instance(1, "tenant1", 2, 2, "instance 2", "https://api.ed-fi.org:443/v7.2/api/data/v3", "https://api.ed-fi.org/v7.2/api/oauth/token", "RvcohKz9zHI4", "E1iEFusaNf81xzCxwHfbolkC", "Completed"),
            });
        })
    .WithName("GetInstances");

app.MapPost(
        "/adminconsole/healthcheck", async (HttpContext context) =>
        {
            // Accessing the HttpContext
            var request = context.Request;
            var response = context.Response;

            // Reading the request body
            using var reader = new StreamReader(request.Body);
            var requestBody = await reader.ReadToEndAsync();

            // Processing the request body (e.g., logging or parsing JSON)
            Console.WriteLine($"Received data: {requestBody}");

            return Results.Created();
        })
    .WithName("PostHealthcheck");

app.MapPost(
        "/connect/token", async (HttpContext context) =>
        {
            // Accessing the HttpContext
            var request = context.Request;
            var response = context.Response;

            // Reading the request body
            using var reader = new StreamReader(request.Body);
            var requestBody = await reader.ReadToEndAsync();

            // Processing the request body (e.g., logging or parsing JSON)
            Console.WriteLine($"Received data: {requestBody}");

            return Results.Ok(
                new Token("eyJhbGciOiJIUzI1NiIsInR5cCI6ImF0K2p3dCJ9.eyJzdWIiOiJ0ZW5hbnQxdXNlciIsIm9pX3Byc3QiOiJ0ZW5hbnQxdXNlciIsImNsaWVudF9pZCI6InRlbmFudDF1c2VyIiwib2lfdGtuX2lkIjoiMSIsInNjb3BlIjoiZWRmaV9hZG1pbl9hcGkvZnVsbF9hY2Nlc3MiLCJqdGkiOiI0Y2Q0ZTNlZC1mZTI0LTQxMzMtODMxMy00YWQxM2UxZjE3YTkiLCJleHAiOjE3Mzc2NTI5NDIsImlzcyI6Imh0dHA6Ly9sb2NhbGhvc3QvYWRtaW5hcGkiLCJpYXQiOjE3Mzc2NTExNDJ9.cseX8soogiF5Ob6Qkctpb6CD-yHxXHRGmEwvAEeMSyo", "", "")
            );
        })
    .WithName("GetToken");

app.Run();



record Tenant(int tenantId, string instanceName, string status);

record Token(string access_token, string token_type, string expires_in);

record Instance(int tenantId, string tenantName, int instanceId, int odsInstanceId, string instanceName, string resourceUrl, string oauthUrl, string clientId, string clientSecret, string status);
