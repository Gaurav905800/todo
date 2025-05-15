const express = require("express");
const router = express.Router();
const todoController = require("../controllers/todo.controller");

// Routes
router.post("/task", todoController.addTodo);

router.get("/task", todoController.getTodos);

router.delete("/task/:id", todoController.deleteTodo);

router.put("/task/:id", todoController.updateTodo);
module.exports = router;
