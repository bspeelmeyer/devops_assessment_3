module.exports = {
  browser = await launch({mongoURI: process.env.DB_URL || "mongodb://localhost:27017/tododb"})
}
