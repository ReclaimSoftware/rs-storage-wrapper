**FS-backed KV storage with value streaming and partial reads**


### constructor

```coffee
{StorageWrapper} = require 'rs-storage-wrapper'

storage = new StorageWrapper {root_dir}
```

If `root_dir` does not exist or is not a directory, this will raise an error whose `.notFound` is `true`.


### FS backing

The key `foo/bar.png` corresponds to the path `#{root_dir}/foo/bar.png`.

Keys must match `/^[ !&'()\[\]a-zA-Z0-9_\/,.+-]+$/` and not contain `".."`.


### get, put, exists, size

```coffee
storage.get key, (e, value) ->
  return ... if e and e.notFound
  return ... if e
  ...

storage.put key, value, (e) ->

storage.exists key, (e, exists) ->

storage.size key, (e, num_bytes) ->
```


### Streams, partial reads

```coffee
storage.createWriteStream key, (e, stream) ->

stream = storage.createReadStream key

stream = storage.createReadStream key, {start, end}
```


### [License: MIT](LICENSE.txt)
