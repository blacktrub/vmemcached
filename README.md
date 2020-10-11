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

# TODO
- ~~set~~
- ~~add~~
- ~~replace~~
- ~~get~~
- ~~delete~~
- ~~incr/decr~~
- ~~flush_all~~
- ~~set with expiration~~
- ~~touch~~
- cas
- append/prepend
- gets
