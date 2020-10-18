# Vmemcached
This is a memcached client library for the V programming langugage (https://vlang.io)

More about client protocol and another memcached stuff you can see [here](https://memcached.org/)

# Installation
```bash
v install blacktrub.vmemcached
```

# Documentation
Each method of this library has test case, so you can use test module as documentation, feel free to open issue if it is not enough

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
