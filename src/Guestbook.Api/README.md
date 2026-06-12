# Guestbook - Aplikacja ASP.NET Core

Prosta aplikacja ASP.NET Core 9.0 - wirtualna księga gości z bazą danych SQL Server.

## ⚡ Szybki start (5 minut)

### Lokalnie
```powershell
dotnet run
```
Aplikacja dostępna: http://localhost:5000

### Na IIS
```powershell
# 1. Opublikuj aplikację
dotnet publish -c Release -o "C:\publish\GuestBook"

# 2. Na serwerze IIS - zaktualizuj connection string w appsettings.json
# 3. Otwórz IIS Manager i utwórz aplikację:
#    - Physical path: C:\publish\GuestBook
#    - App Pool: Utwórz nowy (No Managed Code)
#    - Binding: http://localhost/GuestBook

# 4. Ustaw uprawnienia
icacls "C:\publish\GuestBook" /grant "IIS AppPool\GuestBook:(OI)(CI)R" /T
icacls "C:\publish\GuestBook\logs" /grant "IIS AppPool\GuestBook:(OI)(CI)M" /T

# 5. Zrestartuj IIS
iisreset
```

## 🔧 Konfiguracja

Edytuj plik `appsettings.json`:

```json
{
  "ConnectionStrings": {
    "DefaultConnection": "Server=.\\SQLEXPRESS;Database=GuestBookDb;User=sa;Password=YourPassword123!;TrustServerCertificate=true;"
  }
}
```

**Gdzie zmienić:**
- `Server` - adres SQL Server
- `Database` - nazwa bazy danych
- `User` - login do bazy (np. `sa`)
- `Password` - hasło do użytkownika bazy

**Inne opcje connection string:**

```json
// SQL Server lokalnie
"DefaultConnection": "Server=localhost;Database=GuestBookDb;User=sa;Password=YourPassword123!;TrustServerCertificate=true;"

// SQL Server sieciowy
"DefaultConnection": "Server=sql-server.corp.local;Database=GuestBookDb;User=dbuser;Password=SecurePassword123!;TrustServerCertificate=true;"

// Azure SQL
"DefaultConnection": "Server=yourserver.database.windows.net;Database=GuestBookDb;User=dbuser;Password=YourPassword123!;Encrypt=true;"
```

## 📋 Wymagania

- .NET 9.0 Runtime (lub SDK)
- SQL Server 2016 SP2+
- IIS 7.5+ (do wdrażania)

## 📁 Struktura

```
GuestBook/
├── Models/Guest.cs              # Model
├── Data/GuestBookContext.cs     # DbContext
├── Migrations/                  # Automatyczne migracje
├── Program.cs                   # Aplikacja
├── appsettings.json            # Konfiguracja
└── web.config                  # Konfiguracja IIS
```

## 🚀 Rozwiązywanie problemów

### Błąd 502.5 na IIS
1. Sprawdź logi: `C:\publish\GuestBook\logs\log.txt`
2. Czy .NET Runtime jest zainstalowany: `dotnet --version`
3. Czy SQL Server dostępny: sprawdź connection string
4. Czy app pool ma "No Managed Code"

### Błąd połączenia z bazą
1. Sprawdź czy SQL Server jest dostępny
2. Sprawdź connection string w `appsettings.json`
3. Upewnij się, że baza `GuestBookDb` istnieje

## ✨ Funkcjonalności

- ✅ Dodawanie wpisów (Imię, Email, Wiadomość)
- ✅ Wyświetlanie wszystkich wpisów
- ✅ Automatyczna migracja bazy danych
- ✅ Walidacja danych
- ✅ Ochrona przed SQL Injection

