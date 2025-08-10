using CardValidation.Core.Services;
using CardValidation.Core.Services.Interfaces;
using CardValidation.Infrustructure;

var builder = WebApplication.CreateBuilder(args);
builder.Services.AddHttpLogging(options => {
    options.LoggingFields = Microsoft.AspNetCore.HttpLogging.HttpLoggingFields.All;
    options.RequestBodyLogLimit = 4096;
    options.ResponseBodyLogLimit = 4096;
});

ConfigureServices(builder.Services);

builder.Services.AddHealthChecks();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseStaticFiles();

app.MapHealthChecks("/health");

app.UseAuthorization();

app.Use(async (context, next) =>
{
    var config = context.RequestServices.GetRequiredService<IConfiguration>();
    var enableBodyLogging = config.GetValue<bool>("RequestLogging:EnableBodyLogging");

    if (!enableBodyLogging || context.Request.Path.StartsWithSegments("/health"))
    {
        await next();
        return;
    }

    var logger = context.RequestServices.GetRequiredService<ILogger<Program>>();
    var startTime = DateTime.UtcNow;

    // Capture request
    context.Request.EnableBuffering();
    var requestBody = await new StreamReader(context.Request.Body).ReadToEndAsync();
    context.Request.Body.Position = 0;

    // Log formatted request
    logger.LogInformation($"""
        [{DateTime.UtcNow:HH:mm:ss.fff}] REQUEST:
        Method: {context.Request.Method}
        Path: {context.Request.Path}
        Headers: {string.Join(", ", context.Request.Headers.Select(h => $"{h.Key}={h.Value}"))}
        Body: {requestBody}
        """);

    // Capture response
    var originalBodyStream = context.Response.Body;
    using var responseBody = new MemoryStream();
    context.Response.Body = responseBody;

    await next();

    // Log formatted response
    responseBody.Seek(0, SeekOrigin.Begin);
    var responseContent = await new StreamReader(responseBody).ReadToEndAsync();
    responseBody.Seek(0, SeekOrigin.Begin);

    var duration = DateTime.UtcNow - startTime;
    logger.LogInformation($"""
        [{DateTime.UtcNow:HH:mm:ss.fff}] RESPONSE:
        Status: {context.Response.StatusCode}
        Duration: {duration.TotalMilliseconds}ms
        Body: {responseContent}
        """);

    await responseBody.CopyToAsync(originalBodyStream);
});

app.MapControllers();

app.Run();

void ConfigureServices(IServiceCollection services)
{
    services.AddControllers();
    services.AddEndpointsApiExplorer();
    services.AddSwaggerGen();

    services.AddTransient<ICardValidationService, CardValidationService>();

    services.AddMvc(options =>
    {
        options.Filters.Add(typeof(CreditCardValidationFilter)); ;
    });
}
