module vmemcached

import net

pub struct Connection {
	host string='127.0.0.1'
	port int=11211
}

pub struct Memcached {
	socket net.Socket 
}

pub fn connect(opt Connection) ?Memcached {
	socket := net.dial(opt.host, opt.port) or {
		return error(err)
	}
	return Memcached{socket: socket}
}

pub fn (m Memcached) disconnect() {
	m.socket.close() or {}
}

pub fn (m Memcached) flushall() bool {
	message := 'flush_all\r\n'
	m.socket.write(message) or {
		return false
	}
    response := m.socket.read_line()[0..2]
	return match response {
		'OK' {true}
		else {false}
	}
}
