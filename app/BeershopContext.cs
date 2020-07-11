using System;
using Microsoft.EntityFrameworkCore;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.Extensions.Configuration;

namespace Beershop
{
    public partial class BeershopContext : DbContext
    {

        public IConfiguration Configuration { get; }
        public DbSet<Beer> Beers { get; set; }
        public DbSet<Order> Orders { get; set; }

        public BeershopContext(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseNpgsql(Configuration["PSQL_CONNECTION_STRING"]);
            }
        }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            OnModelCreatingPartial(modelBuilder);

            modelBuilder.Entity<Beer>().HasData(new Beer { Id = Guid.NewGuid(), Name = "Stella" });
            modelBuilder.Entity<Beer>().HasData(new Beer { Id = Guid.NewGuid(), Name = "Budweiser" });
            modelBuilder.Entity<Beer>().HasData(new Beer { Id = Guid.NewGuid(), Name = "Becks" });
        }

        partial void OnModelCreatingPartial(ModelBuilder modelBuilder);

    }

    public class Beer
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public Guid Id { get; set; }
        public string Name { get; set; }
        public Double Price { get; set; }
    }

    public class Order
    {
        [Key]
        [DatabaseGenerated(DatabaseGeneratedOption.Identity)]
        public Guid Id { get; set; }
        public Boolean Processed { get; set; }
        public DateTime CreatedAt { get; set; }
        public Beer Beer { get; set; }
    }
}
