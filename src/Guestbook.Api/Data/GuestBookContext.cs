using GuestBook.Models;
using Microsoft.EntityFrameworkCore;

namespace GuestBook.Data
{
    public class GuestBookContext : DbContext
    {
        public GuestBookContext(DbContextOptions<GuestBookContext> options) : base(options)
        {
        }

        public DbSet<Guest> Guests { get; set; }
    }
}
