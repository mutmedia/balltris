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
    const result = await this.db.collection(this.name).updateOne(query, {$set: update});
    if (!result) {
      throw new Error('Db updateOne error for ' + this.name);
    }
    return result;
  }

  async find(query, limit, sort) {
    const result = [];
    let cursor = await this.db.collection(this.name).find(query);

    if (sort) {
      cursor = await cursor.sort(sort)
    }

    if (limit) {
      cursor = await cursor.limit(limit);
    }

    if (!cursor) {
      throw new Error('Db find error for ' + this.name);
    }

    for (let doc = await cursor.next(); doc != null; doc = await cursor.next()) {
      result.push(doc);
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
