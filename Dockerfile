# Stage 1: Build the application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

# Copy all .csproj files and restore them as a single layer to be cached
COPY ["CardValidation.sln", "./"]
COPY ["CardValidation.Core/CardValidation.Core.csproj", "CardValidation.Core/"]
COPY ["CardValidation.Web/CardValidation.Web.csproj", "CardValidation.Web/"]
COPY ["CardValidation.Tests/CardValidation.Tests.csproj", "CardValidation.Tests/"]
RUN dotnet restore "CardValidation.sln"

# Copy the rest of the source code
COPY . .
WORKDIR "/src/CardValidation.Web"
RUN dotnet build "CardValidation.Web.csproj" -c Release -o /app/build

# Stage 2: Publish the application
FROM build AS publish
RUN dotnet publish "CardValidation.Web.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Stage 3: Create the final runtime image
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
# Install curl for the readiness check
RUN apt-get update && apt-get install -y curl
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "CardValidation.Web.dll"]