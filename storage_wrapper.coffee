fs = require 'fs'
_ = require 'underscore'
mkdirp = require 'mkdirp'

class StorageWrapper
  constructor: (opt) ->
    throw new Error "usage: new StorageWrapper {root_dir}" if not opt
    {@root_dir} = opt
    @_validate_root_dir()

  get: (key, c=(->)) ->
    @_validate_key key
    fs.readFile @_path_for(key), (e, value) ->
      e.notFound = true if e and e.code == 'ENOENT'
      c e, value

  put: (key, value, c=(->)) ->
    @_validate_key key
    @_mkdirp_parent key, (e) =>
      return c e if e
      fs.writeFile @_path_for(key), value, c

  exists: (key, c) ->
    @_validate_key key
    fs.exists @_path_for(key), (exists) ->
      c null, exists

  size: (key, c) ->
    @_validate_key key
    fs.stat @_path_for(key), (e, stats) ->
      e.notFound = true if e and e.code == 'ENOENT'
      return c e if e
      c null, stats.size

  createReadStream: (key, opt={}) ->
    @_validate_key key
    opt = _.pick opt, 'start', 'end'
    fs.createReadStream @_path_for(key), opt

  createWriteStream: (key, c=(->)) ->
    @_validate_key key
    @_mkdirp_parent key, (e) =>
      return c e if e
      c null, fs.createWriteStream @_path_for(key)

  _path_for: (key) ->
    "#{@root_dir}/#{key}"

  _mkdirp_parent: (key, c) ->
    bits = key.split('/')
    return c null if bits.length == 1
    dir = @root_dir + '/' + bits.slice(0, bits.length - 1).join('/')
    mkdirp dir, c

  _validate_key: (key) ->
    if not key.match /^[ !&'()\[\]@a-zA-Z0-9_\/,.+-]+$/
      throw new Error "invalid key: #{JSON.stringify key}"
    if key.indexOf("..") != -1
      throw new Error "invalid key: #{JSON.stringify key}"

  _validate_root_dir: () ->
    throw new Error "root_dir not specified" if not @root_dir
    if not fs.existsSync @root_dir
      throw new Error "root_dir does not exist"
    if not fs.statSync(@root_dir).isDirectory()
      throw new Error "root_dir is not a directory"


module.exports = {StorageWrapper}
