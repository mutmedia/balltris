const ObjectId = require('mongodb').ObjectID;
class Model {
  constructor(db, collectionName) {
    this.name = collectionName;
    this.db = db;
  }

  async insertOne(data) {
    const operation = await this.db.collection(this.name).insertOne(data);
    if (operation.result.ok !== 1 || operation.ops.length !== 1) {
      throw new Error('Db insertOne failed for ' + this.name);
    }
    return operation.ops[0];
  }

  async findOne(query) {
    const result = await this.db.collection(this.name).findOne(query);
    if (!result) {
      throw new Error('Db findOne error for ' + this.name);
    }
    return result;
  }

  async updateOne(query, update) {
    const result = await this.db.collection(this.name).updateOne(query, {$set: {update}});
    if (!result) {
      throw new Error('Db updateOne error for ' + this.name);
    }
    return result;
  }

  async find() {
    const result = []
    const cursor = await this.db.collection(this.name).find();
    for (let doc = await cursor.next(); doc != null; doc = await cursor.next()) {
      result.push(doc);
    }
    if (!result) {
      throw new Error('Db findOneById error for ' + this.name);
    }
    return result;
  }

  createUniqueIndex(key) {
    const spec = {};
    spec[key] = 1;
    this.db.collection(this.name).createIndex(spec, {unique: true});
  }

}

module.exports = Model
