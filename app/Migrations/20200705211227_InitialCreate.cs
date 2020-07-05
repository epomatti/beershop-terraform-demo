using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace app.Migrations
{
    public partial class InitialCreate : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Beers",
                columns: table => new
                {
                    Id = table.Column<Guid>(nullable: false),
                    Name = table.Column<string>(nullable: true),
                    Price = table.Column<double>(nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Beers", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Orders",
                columns: table => new
                {
                    Id = table.Column<Guid>(nullable: false),
                    Processed = table.Column<bool>(nullable: false),
                    BeerId = table.Column<Guid>(nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Orders", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Orders_Beers_BeerId",
                        column: x => x.BeerId,
                        principalTable: "Beers",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.InsertData(
                table: "Beers",
                columns: new[] { "Id", "Name", "Price" },
                values: new object[] { new Guid("e77b538b-9692-42fc-88c8-b999909e22f5"), "Stella", 0.0 });

            migrationBuilder.InsertData(
                table: "Beers",
                columns: new[] { "Id", "Name", "Price" },
                values: new object[] { new Guid("84503a25-2bee-4809-822a-6bf07f494bca"), "Budweiser", 0.0 });

            migrationBuilder.InsertData(
                table: "Beers",
                columns: new[] { "Id", "Name", "Price" },
                values: new object[] { new Guid("dfd14047-d6d2-4775-b553-7c1f056c8e9b"), "Becks", 0.0 });

            migrationBuilder.CreateIndex(
                name: "IX_Orders_BeerId",
                table: "Orders",
                column: "BeerId");
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Orders");

            migrationBuilder.DropTable(
                name: "Beers");
        }
    }
}
