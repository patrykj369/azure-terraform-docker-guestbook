using GuestBook.Data;
using GuestBook.Models;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add DbContext
builder.Services.AddDbContext<GuestBookContext>(options =>
{
    options.UseSqlServer(builder.Configuration.GetConnectionString("DefaultConnection"));
    options.ConfigureWarnings(w => w.Ignore(Microsoft.EntityFrameworkCore.Diagnostics.RelationalEventId.PendingModelChangesWarning));
});

var app = builder.Build();

// Apply migrations automatically
using (var scope = app.Services.CreateScope())
{
    var dbContext = scope.ServiceProvider.GetRequiredService<GuestBookContext>();
    dbContext.Database.Migrate();
}

// GET - Display all guests
app.MapGet("/", async (GuestBookContext db) =>
{
    var guests = await db.Guests.OrderByDescending(g => g.CreatedAt).ToListAsync();
    var html = GenerateHtml(guests);
    return Results.Content(html, "text/html");
});

// POST - Add new guest
app.MapPost("/add-guest", async (GuestBookContext db, HttpRequest request) =>
{
    try
    {
        var form = await request.ReadFormAsync();
        var name = form["name"].ToString();
        var email = form["email"].ToString();
        var message = form["message"].ToString();

        if (string.IsNullOrWhiteSpace(name) || string.IsNullOrWhiteSpace(email))
        {
            return Results.BadRequest("Nazwa i email są wymagane.");
        }

        var guest = new Guest
        {
            Name = name,
            Email = email,
            Message = message,
            CreatedAt = DateTime.UtcNow
        };

        db.Guests.Add(guest);
        await db.SaveChangesAsync();

        return Results.Redirect("/");
    }
    catch (Exception ex)
    {
        return Results.BadRequest($"Błąd: {ex.Message}");
    }
});

app.Run();

// Helper method to generate HTML
string GenerateHtml(List<Guest> guests)
{
    var guestRows = string.Empty;
    foreach (var guest in guests)
    {
        guestRows += $@"
            <tr>
                <td>{System.Net.WebUtility.HtmlEncode(guest.Name)}</td>
                <td>{System.Net.WebUtility.HtmlEncode(guest.Email)}</td>
                <td>{System.Net.WebUtility.HtmlEncode(guest.Message)}</td>
                <td>{guest.CreatedAt:yyyy-MM-dd HH:mm:ss}</td>
            </tr>";
    }

    return $@"
<!DOCTYPE html>
<html lang=""pl"">
<head>
    <meta charset=""UTF-8"">
    <meta name=""viewport"" content=""width=device-width, initial-scale=1.0"">
    <title>Księga Gości</title>
    <style>
        body {{
            font-family: Arial, sans-serif;
            max-width: 900px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }}
        h1 {{
            color: #333;
            text-align: center;
        }}
        .form-container {{
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }}
        .form-group {{
            margin-bottom: 15px;
        }}
        label {{
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
            color: #333;
        }}
        input, textarea {{
            width: 100%;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
            font-family: Arial, sans-serif;
        }}
        textarea {{
            resize: vertical;
            min-height: 100px;
        }}
        button {{
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }}
        button:hover {{
            background-color: #45a049;
        }}
        .guests-container {{
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }}
        table {{
            width: 100%;
            border-collapse: collapse;
        }}
        th {{
            background-color: #4CAF50;
            color: white;
            padding: 12px;
            text-align: left;
        }}
        td {{
            padding: 12px;
            border-bottom: 1px solid #ddd;
        }}
        tr:hover {{
            background-color: #f9f9f9;
        }}
        .no-guests {{
            text-align: center;
            padding: 40px;
            color: #999;
        }}
    </style>
</head>
<body>
    <h1>📖 Wirtualna Księga Gości</h1>
    
    <div class=""form-container"">
        <h2>Wpisz się do księgi</h2>
        <form method=""post"" action=""/add-guest"">
            <div class=""form-group"">
                <label for=""name"">Imię i Nazwisko *</label>
                <input type=""text"" id=""name"" name=""name"" required>
            </div>
            <div class=""form-group"">
                <label for=""email"">Email *</label>
                <input type=""email"" id=""email"" name=""email"" required>
            </div>
            <div class=""form-group"">
                <label for=""message"">Wiadomość</label>
                <textarea id=""message"" name=""message"" placeholder=""Napisz swoją wiadomość...""></textarea>
            </div>
            <button type=""submit"">Dodaj wpis</button>
        </form>
    </div>

    <div class=""guests-container"">
        <h2>Wpisy gości ({guests.Count})</h2>
        {(guests.Count == 0 ?
            "<div class=\"no-guests\">Brak wpisów. Bądź pierwszy!</div>" :
            $@"<table>
                <thead>
                    <tr>
                        <th>Imię i Nazwisko</th>
                        <th>Email</th>
                        <th>Wiadomość</th>
                        <th>Data</th>
                    </tr>
                </thead>
                <tbody>
                    {guestRows}
                </tbody>
            </table>")}
    </div>
</body>
</html>";
}
