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
router.post('/users', async (ctx, next) => {
  const data = ctx.request.body;
  ctx.body = await db.User.insertOne(data);
});
router.get('/users/:id', async (ctx, next) => {
  const id = ctx.params.id;
  ctx.body = await db.User.findOneById(id);
});

//router.get('/users', users.all);
//router.get('/users/:id', users.getSingle);
router.get('/error/test', async () => {
  throw Error('Error handling works')
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
