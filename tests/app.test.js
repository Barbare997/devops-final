const request = require('supertest');
const app = require('../src/app');
const store = require('../src/store');

describe('Todo app', () => {
  beforeEach(() => {
    store.reset();
  });

  test('GET /health returns ok payload', async () => {
    const res = await request(app).get('/health').expect(200);
    expect(res.body.ok).toBe(true);
    expect(res.body).toHaveProperty('version');
  });

  test('POST /todos creates a todo (JSON)', async () => {
    const res = await request(app)
      .post('/todos')
      .set('Accept', 'application/json')
      .send({ title: 'Buy milk' })
      .expect(201);

    expect(res.body.todo.title).toBe('Buy milk');
    expect(res.body.todo.id).toBe(1);
  });

  test('GET /todos/:id is a dynamic route for a single todo', async () => {
    await request(app)
      .post('/todos')
      .set('Accept', 'application/json')
      .send({ title: 'Walk dog' })
      .expect(201);

    const res = await request(app).get('/todos/1').expect(200);
    expect(res.body.todo.title).toBe('Walk dog');
  });

  test('GET /todos/:id returns 404 when missing', async () => {
    await request(app).get('/todos/99').expect(404);
  });
});
