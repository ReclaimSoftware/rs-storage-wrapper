{StorageWrapper} = require '../index'
assert = require 'assert'
{read_stream} = require 'rs-util'

describe "StorageWrapper", () ->

  describe "constructor", () ->

    it "errors if no args are given", () ->
      assert_throws "usage: new StorageWrapper {root_dir}", () ->
        new StorageWrapper()

    it "errors if root_dir is not specified", () ->
      assert_throws "root_dir not specified", () ->
        new StorageWrapper {}

    it "throws 'root_dir does not exist'", () ->
      assert_throws "root_dir does not exist", () ->
        new StorageWrapper {root_dir: "#{__dirname}/asdf404"}

    it "throws 'root_dir is not a directory'", () ->
      assert_throws "root_dir is not a directory", () ->
        new StorageWrapper {root_dir: "#{__dirname}/fixtures/foo"}


  describe "get", () ->
    storage = new StorageWrapper {root_dir: "#{__dirname}/fixtures"}

    it "validates that the key does not contain ..", () ->
      assert_throws 'invalid key: "../../.ssh/id_rsa"', () ->
        storage.get '../../.ssh/id_rsa'

    it "validates that the key does not contain unexpected characters", () ->
      assert_throws 'invalid key: "épée"', () ->
        storage.get 'épée'

    it "gets an existing file", (done) ->
      storage.get 'foo', (e, value) ->
        assert.ok not e
        assert.ok Buffer.isBuffer value
        assert.equal value.toString(), "Foo\n"
        done()

    it "errors with .notFound if file DNE", (done) ->
      storage.get '404', (e, value) ->
        assert.ok e
        assert.strictEqual e.notFound, true
        done()


  describe "put", () ->
    storage = new StorageWrapper {root_dir: "#{__dirname}/fixtures"}

    it "validates that the key does not contain ..", () ->
      assert_throws 'invalid key: "../../.ssh/id_rsa"', () ->
        storage.put '../../.ssh/id_rsa', 'value'

    it "validates that the key does not contain unexpected characters", () ->
      assert_throws 'invalid key: "épée"', () ->
        storage.put 'épée', 'value'

    it "puts", (done) ->
      data = new Buffer Math.random().toFixed(20)
      storage.put 'temp/misc/random', data, (e) ->
        assert.ok not e
        storage.get 'temp/misc/random', (e, value) ->
          assert.equal value.toString('hex'), data.toString('hex')
          done()


  describe "exists", () ->
    storage = new StorageWrapper {root_dir: "#{__dirname}/fixtures"}

    it "validates that the key does not contain ..", () ->
      assert_throws 'invalid key: "../../.ssh/id_rsa"', () ->
        storage.exists '../../.ssh/id_rsa'

    it "validates that the key does not contain unexpected characters", () ->
      assert_throws 'invalid key: "épée"', () ->
        storage.exists 'épée'

    it "gives true when the file exists", () ->
      storage.exists 'foo', (e, exists) ->
        assert.ok not e
        assert.strictEqual exists, true

    it "gives false when the file does not exist", () ->
      storage.exists '404', (e, exists) ->
        assert.ok not e
        assert.strictEqual exists, false


  describe "size", () ->
    storage = new StorageWrapper {root_dir: "#{__dirname}/fixtures"}

    it "validates that the key does not contain ..", () ->
      assert_throws 'invalid key: "../../.ssh/id_rsa"', () ->
        storage.size '../../.ssh/id_rsa'

    it "validates that the key does not contain unexpected characters", () ->
      assert_throws 'invalid key: "épée"', () ->
        storage.size 'épée'

    it "errors with .notFound if the file does not exist", () ->
      storage.size '404', (e, size) ->
        assert.ok e
        assert.strictEqual e.notFound, true

    it "gives the size of the file", () ->
      storage.size 'foo', (e, size) ->
        assert.ok not e
        assert.equal size, 4


  describe "createReadStream", () ->
    storage = new StorageWrapper {root_dir: "#{__dirname}/fixtures"}

    it "validates that the key does not contain ..", () ->
      assert_throws 'invalid key: "../../.ssh/id_rsa"', () ->
        storage.createReadStream '../../.ssh/id_rsa'

    it "validates that the key does not contain unexpected characters", () ->
      assert_throws 'invalid key: "épée"', () ->
        storage.createReadStream 'épée'

    it "returns a readstream of the file", (done) ->
      stream = storage.createReadStream 'foo'
      read_stream stream, (e, data) ->
        assert.equal data.toString(), "Foo\n"
        done()

    it "supports {start, end}", (done) ->
      stream = storage.createReadStream 'foo', start: 1, end: 2
      read_stream stream, (e, data) ->
        assert.equal data.toString(), "oo"
        done()


  describe "createWriteStream", () ->
    storage = new StorageWrapper {root_dir: "#{__dirname}/fixtures"}

    it "validates that the key does not contain ..", () ->
      assert_throws 'invalid key: "../../.ssh/id_rsa"', () ->
        storage.createWriteStream '../../.ssh/id_rsa'

    it "validates that the key does not contain unexpected characters", () ->
      assert_throws 'invalid key: "épée"', () ->
        storage.createWriteStream 'épée'

    it "creates a writestream", (done) ->
      data = new Buffer Math.random().toFixed(20)
      storage.createWriteStream 'temp/misc/random', (e, stream) ->
        assert.ok not e
        stream.end data, () ->
          stream = storage.createReadStream 'temp/misc/random'
          read_stream stream, (e, result) ->
            assert.equal result.toString('hex'), data.toString('hex')
            done()


assert_throws = (message, f) ->
  try
    f()
  catch e
    assert.equal e.message, message
    return
  throw new Error 'expected an error'
