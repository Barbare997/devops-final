let todos = [];
let nextId = 1;

function reset() {
  todos = [];
  nextId = 1;
}

function listTodos() {
  return [...todos];
}

function getById(id) {
  const numeric = Number(id);
  if (!Number.isInteger(numeric) || numeric < 1) {
    return null;
  }
  return todos.find((t) => t.id === numeric) || null;
}

function addTodo(title) {
  const trimmed = String(title || '').trim();
  if (!trimmed) {
    return null;
  }
  const todo = { id: nextId++, title: trimmed, done: false };
  todos.push(todo);
  return todo;
}

function toggleTodo(id) {
  const todo = getById(id);
  if (!todo) {
    return null;
  }
  todo.done = !todo.done;
  return todo;
}

module.exports = {
  reset,
  listTodos,
  getById,
  addTodo,
  toggleTodo
};
