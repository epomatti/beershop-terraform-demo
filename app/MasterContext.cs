using System;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace app
{
    public partial class MasterContext : DbContext
    {
        public DbSet<Beer> Beers { get; set; }
        public DbSet<Order> Orders { get; set; }

        public MasterContext()
        {
        }

        public MasterContext(DbContextOptions<MasterContext> options)
            : base(options)
        {
        }

        protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
        {
            if (!optionsBuilder.IsConfigured)
            {
                optionsBuilder.UseSqlServer("Name=BeershopDatabase");
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
