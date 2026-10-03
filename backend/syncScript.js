import db from "./src/models/index.js";

async function syncDatabase() {
  try {
    console.log("Database Starting Sync....");
    await db.connection.authenticate();
    await db.connection.query("SET FOREIGN_KEY_CHECKS = 0");

    // await db.User.sync({
    //   alter: true,
    // });

    // await db.Category.sync({
    //   alter: true,
    // });

    // await db.Product.sync({
    //   alter: true,
    // });

    // await db.Notification.sync({
    //   alter: true,
    // });

    await db.Wishlist.sync({
      alter: true
    })

    await db.connection.query("SET FOREIGN_KEY_CHECKS = 1");
    console.log("Database synchronized successfully.");
  } catch (error) {
    console.log("Error during database sync..." + error.message);
    process.exit(1);
  }
}
syncDatabase();

