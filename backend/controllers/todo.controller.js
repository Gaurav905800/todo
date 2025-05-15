const { json } = require("express");
const Todo = require("../models/todo.model");

exports.addTodo = async (req, res) => {
  const { title, description, completed, priority } = req.body;

  if (!title || completed === undefined || !priority) {
    return res
      .status(400)
      .json({ message: "Please provide all required fields" });
  }

  try {
    const newTodo = new Todo({
      title,
      description,
      completed,
      priority,
    });
    await newTodo.save();
    return res
      .status(201)
      .json({ message: "Todo created successfully", todo: newTodo });
  } catch (error) {
    return res.status(500).json({ message: error.message || "Server Error" });
  }
};

exports.getTodos = async (req, res) => {
  try {
    const todos = await Todo.find();
    return res.status(200).json({ todos });
  } catch (error) {
    return res.status(404).json({ message: error.message || "Server Error" });
  }
};

exports.deleteTodo = async (req, res) => {
  try {
    const todo = await Todo.findByIdAndDelete(req.params.id);
    if (!todo) {
      return res.status(404).json({ message: "Todo not found" });
    }
    return res.status(200).json({ message: "Todo deleted successfully" });
  } catch (error) {
    return res.status(500).json({ message: error.message || "Server Error" });
  }
};

exports.updateTodo = async (req, res) => {
  const { title, description, completed, priority } = req.body;

  if (!title || completed === undefined || !priority) {
    return res
      .status(400)
      .json({ message: "Please provide all required fields" });
  }

  try {
    const todo = await Todo.findByIdAndUpdate(
      req.params.id,
      { title, description, completed, priority },
      { new: true }
    );
    if (!todo) {
      return res.status(404).json({ message: "Todo not found" });
    }
    return res.status(200).json({ message: "Todo updated successfully", todo });
  } catch (error) {
    return res.status(500).json({ message: error.message || "Server Error" });
  }
};
