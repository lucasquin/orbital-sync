FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 5000

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["Ping.csproj", "."]
RUN dotnet restore "./Ping.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "Ping.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Ping.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Ping.dll"]
