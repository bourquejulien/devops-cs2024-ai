﻿FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 4000

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["Validation/Validation.csproj", "Validation/"]
RUN dotnet restore "Validation/Validation.csproj"
COPY . .
WORKDIR "/src/Validation"
RUN dotnet build "Validation.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "Validation.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final

#ENV TeamName
#ENV TableStorageAccountName
#ENV TableStorageAccountKey


WORKDIR /app
COPY Validation/passwords.txt .
COPY Validation/passwords_hashed.txt .
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Validation.dll"]
