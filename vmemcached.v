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

fn clean_response(response string) string {
	return response.replace('\r\n', '')
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
	msg := 'get $key'
	m.socket.write(msg) or {
		return Value{}
	}
	response := m.socket.read_line()
	if response == 'END\r\n' {
		return Value{}
	}
	value := m.socket.read_line()
	return Value{clean_response(value)}
}

pub fn (m Memcached) set(key string, val string, exp int) bool {
	m.socket.write('set $key 0 $exp $val.len') or {
		return false
	}
	m.socket.write('$val') or {
		return false
	}
	response := m.socket.read_line()[0..6]
	return match response {
		'STORED' { true }
		else { false }
	}
}

pub fn (m Memcached) replace(key string, val string, exp int) bool {
	m.socket.write('replace $key 0 $exp $val.len') or {
		return false
	}
	m.socket.write('$val') or {
		return false
	}
	response := clean_response(m.socket.read_line())
	return match response {
		'STORED' { true }
		else { false }
	}
}

pub fn (m Memcached) delete(key string) bool {
	msg := 'delete $key'
	m.socket.write(msg) or {
		return false
	}
	response := clean_response(m.socket.read_line())
	return match response {
		'DELETED' { true }
		else { false }
	}
}

pub fn (m Memcached) add(key string, val string, exp int) bool {
	m.socket.write('add $key 0 $exp $val.len') or {
		return false
	}
	m.socket.write('$val') or {
		return false
	}
	response := clean_response(m.socket.read_line())
	return match response {
		'STORED' { true }
		else { false }
	}
}

pub fn (m Memcached) incr(key string, val string) bool {
	msg := 'incr $key $val'
	m.socket.write(msg) or {
		return false
	}
	response := clean_response(m.socket.read_line())
	return match response {
		'NOT_FOUND' { false }
		else { true }
	}
}

pub fn (m Memcached) decr(key string, val string) bool {
	msg := 'decr $key $val'
	m.socket.write(msg) or {
		return false
	}
	response := clean_response(m.socket.read_line())
	return match response {
		'NOT_FOUND' { false }
		else { true }
	}
}

pub fn (m Memcached) touch(key string, exp int) bool {
	msg := 'touch $key $exp'
	m.socket.write(msg) or {
		return false
	}
	response := clean_response(m.socket.read_line())
	return match response {
		'TOUCHED' { true }
		else { false }
	}
}
