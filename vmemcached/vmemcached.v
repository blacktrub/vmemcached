module vmemcached

import net

pub struct Connection {
	host string = '127.0.0.1'
	port int = 11211
}

pub struct Memcached {
	socket net.Socket
}

pub struct Value {
pub:
	content string
}

pub fn connect(opt Connection) ?Memcached {
	socket := net.dial(opt.host, opt.port) or {
		return error(err)
	}
	return Memcached{
		socket: socket
	}
}

pub fn (m Memcached) disconnect() {
	m.socket.close() or { }
}

pub fn (m Memcached) flushall() bool {
	message := 'flush_all\r\n'
	m.socket.write(message) or {
		return false
	}
	response := m.socket.read_line()[0..2]
	return match response {
		'OK' { true }
		else { false }
	}
}

pub fn (m Memcached) get(key string) Value {
	msg := 'get $key\r\n'
	m.socket.write(msg) or {
		return Value{}
	}
	response := m.socket.read_line()
	if response == 'END\r\n' {
		return Value{}
	}
	m.socket.read_line()
	value := m.socket.read_line()
	return Value{value.replace('\r\n', '')}
}

pub fn (m Memcached) set(key, val string) bool {
	msg := 'set $key 0 0 $val.len\r\n$val\r\n'
	m.socket.write(msg) or {
		return false
	}
	response := m.socket.read_line()[0..6]
	return match response {
		'STORED' { true }
		else { false }
	}
}
