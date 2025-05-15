require("dotenv").config();
const express = require("express");
const todoRoutes = require("./routes/todo.route");
const { connectMongoDb } = require("./connection");

const app = express();
const PORT = process.env.PORT;
const MONGODB_URI = process.env.MONGODB_URI;

// MongoDB connection
connectMongoDb(MONGODB_URI);

app.use(express.json());

app.use("/api", todoRoutes);

app.listen(PORT, () => console.log(`Server is running on port ${PORT}`));
