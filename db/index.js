const MongoClient = require('mongodb').MongoClient;
const config = require('config');
const Model = require('./model');

let db;

class Db {
  async connect() {
    if(!db) {
      db = await MongoClient.connect(config.db.url);
      this.User = new Model(db, 'users');
      //this.User.createUniqueIndex('username');
      this.Game = new Model(db, 'games');
    }
  }
};

module.exports = new Db();
