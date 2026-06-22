FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY ["src/Guestbook.Api/GuestBook.csproj", "src/Guestbook.Api/"]
RUN dotnet restore "src/Guestbook.Api/GuestBook.csproj"
COPY . .
RUN dotnet publish "src/Guestbook.Api/GuestBook.csproj" -c Release -o /app/publish --no-restore /p:UseAppHost=false



FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS final
WORKDIR /app
ENV ASPNETCORE_HTTP_PORTS=8080
EXPOSE 8080
COPY --from=build /app/publish .
USER app
ENTRYPOINT ["dotnet", "GuestBook.dll"]