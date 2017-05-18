const Koa = require('koa');
const Router = require('koa-router');
const bodyParser = require('koa-bodyparser')
const config = require('config')
const db = require('./db')

const app = new Koa();
const router = new Router()

// Error handling
app.use(async (ctx, next) => {
  try {
    await next();
  } catch (e) {
    const resError = {
      code: 500,
      message: e.message,
      errors: e.errors
    };
    if (e instanceof Error) {
      Object.assign(resError, {stack: e.stack});
    }
    Object.assign(ctx, {body: resError, status: e.status || 500});
  }
});
app.use(bodyParser());

router.get('/', (ctx) => ctx.body = {hello: 'world'})

router.get('/users', async (ctx, next) => {
  ctx.body = await db.User.find();
});
router.post('/users', async (ctx, next) => {
  const data = ctx.request.body;
  ctx.body = await db.User.insertOne(data);
});

router.get('/users/:username', async (ctx, next) => {
  const username = ctx.params.username;
  ctx.body = await db.User.findOne({username: username});
});
router.patch('/users/:username', async (ctx, next) => {
  const username = ctx.params.username;
  ctx.body = await db.User.updateOne({username: username}, ctx.request.body);
});

app.use(router.routes())

db.connect()
  .then(() => {

    app.listen(config.port, () => {
      console.info(`Listening to http://localhost:${config.port}`);
    });
  })
  .catch((err) => {
    console.error('ERROR:', err)
  });
