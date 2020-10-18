# Installation
```bash
v install blacktrub.vmemcached
```

# Quick start example
```v
module main

import blacktrub.vmemcached

fn main() {
    m := vmemcached.connect(vmemcached.Connection{}) or {
        panic(err)
    }
    println(m.get('foo'))
}
```

# How run tests
For run tests you must run docker container with memcached
```bash
docker run -d --name mmhed -p 11211:11211 memcached -vv
```

And just run tests in project directory
```v
v test .
```
