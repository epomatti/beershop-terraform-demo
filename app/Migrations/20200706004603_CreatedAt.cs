using System;
using Microsoft.EntityFrameworkCore.Migrations;

namespace app.Migrations
{
    public partial class CreatedAt : Migration
    {
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Beers",
                keyColumn: "Id",
                keyValue: new Guid("84503a25-2bee-4809-822a-6bf07f494bca"));

            migrationBuilder.DeleteData(
                table: "Beers",
                keyColumn: "Id",
                keyValue: new Guid("dfd14047-d6d2-4775-b553-7c1f056c8e9b"));

            migrationBuilder.DeleteData(
                table: "Beers",
                keyColumn: "Id",
                keyValue: new Guid("e77b538b-9692-42fc-88c8-b999909e22f5"));

            migrationBuilder.AddColumn<DateTime>(
                name: "CreatedAt",
                table: "Orders",
                nullable: false,
                defaultValue: new DateTime(1, 1, 1, 0, 0, 0, 0, DateTimeKind.Unspecified));

            migrationBuilder.InsertData(
                table: "Beers",
                columns: new[] { "Id", "Name", "Price" },
                values: new object[] { new Guid("286769d9-3a95-45d0-9ff9-4a293d8a94e1"), "Stella", 0.0 });

            migrationBuilder.InsertData(
                table: "Beers",
                columns: new[] { "Id", "Name", "Price" },
                values: new object[] { new Guid("da35fc72-1a89-48bb-895d-165331c50e69"), "Budweiser", 0.0 });

            migrationBuilder.InsertData(
                table: "Beers",
                columns: new[] { "Id", "Name", "Price" },
                values: new object[] { new Guid("10fd7e70-2e8a-40b8-90fb-bb9eaaaca955"), "Becks", 0.0 });
        }

        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "Beers",
                keyColumn: "Id",
                keyValue: new Guid("10fd7e70-2e8a-40b8-90fb-bb9eaaaca955"));

            migrationBuilder.DeleteData(
                table: "Beers",
                keyColumn: "Id",
                keyValue: new Guid("286769d9-3a95-45d0-9ff9-4a293d8a94e1"));

            migrationBuilder.DeleteData(
                table: "Beers",
                keyColumn: "Id",
                keyValue: new Guid("da35fc72-1a89-48bb-895d-165331c50e69"));

            migrationBuilder.DropColumn(
                name: "CreatedAt",
                table: "Orders");

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
        }
    }
}
