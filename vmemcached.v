module vmemcached

import net

pub struct Connection {
	host string = '127.0.0.1'
	port int    = 11211
}

pub struct Memcached {
mut:
	socket net.TcpConn
}

pub struct Value {
pub:
	content string
	casid   string
}

fn clean_response(response string) string {
	return response.replace('\r\n', '')
}

pub fn connect(opt Connection) ?Memcached {
	socket := net.dial_tcp('$opt.host:$opt.port') ?
	return Memcached{
		socket: socket
	}
}

pub fn (m Memcached) disconnect() {
	m.socket.close() or { }
}

pub fn (m Memcached) read() ?string {
	mut buf := []byte{len: 1024}
	nbytes := m.socket.read(mut buf) ?
	received := buf[0..nbytes].bytestr()
	return clean_response(received)
}

pub fn (m Memcached) read_multi() ?[]string {
	mut buf := []byte{len: 1024}
	nbytes := m.socket.read(mut buf) ?
	received := buf[0..nbytes].bytestr()
	return received.split('\r\n').filter(it != '')
}

pub fn (m Memcached) write(msg string) ? {
	m.socket.write_str('$msg\r\n')
	return none
}

pub fn (m Memcached) flushall() bool {
	message := 'flush_all'
	m.write(message) or { return false }
	response := m.read() or { return false }
	return match response {
		'OK' { true }
		else { false }
	}
}

// TODO: use optional typing
pub fn (m Memcached) get(key string) Value {
	msg := 'get $key'
	m.write(msg) or { return Value{} }
	response := m.read_multi() or { return Value{} }
	if response[0] == 'END' {
		return Value{}
	}
	value := response[1]
	return Value{value, ''}
}

pub fn (m Memcached) set(key string, val string, exp int) bool {
	m.write('set $key 0 $exp $val.len') or { return false }
	m.write('$val') or { return false }
	response := m.read() or { return false }
	return match response {
		'STORED' { true }
		else { false }
	}
}

pub fn (m Memcached) replace(key string, val string, exp int) bool {
	m.write('replace $key 0 $exp $val.len') or { return false }
	m.write('$val') or { return false }
	response := m.read() or { return false }
	return match response {
		'STORED' { true }
		else { false }
	}
}

pub fn (m Memcached) delete(key string) bool {
	msg := 'delete $key'
	m.write(msg) or { return false }
	response := m.read() or { return false }
	return match response {
		'DELETED' { true }
		else { false }
	}
}

pub fn (m Memcached) add(key string, val string, exp int) bool {
	m.write('add $key 0 $exp $val.len') or { return false }
	m.write('$val') or { return false }
	response := m.read() or { return false }
	return match response {
		'STORED' { true }
		else { false }
	}
}

pub fn (m Memcached) incr(key string, val string) bool {
	msg := 'incr $key $val'
	m.write(msg) or { return false }
	response := m.read() or { return false }
	return match response {
		'NOT_FOUND' { false }
		else { true }
	}
}

pub fn (m Memcached) decr(key string, val string) bool {
	msg := 'decr $key $val'
	m.write(msg) or { return false }
	response := m.read() or { return false }
	return match response {
		'NOT_FOUND' { false }
		else { true }
	}
}

pub fn (m Memcached) touch(key string, exp int) bool {
	msg := 'touch $key $exp'
	m.write(msg) or { return false }
	response := m.read() or { return false }
	return match response {
		'TOUCHED' { true }
		else { false }
	}
}

pub fn (m Memcached) append(key string, val string) bool {
	msg := 'append $key 0 0 $val.len'
	m.write(msg) or { return false }
	m.write('$val') or { return false }
	response := m.read() or { return false }
	return match response {
		'STORED' { true }
		else { false }
	}
}

pub fn (m Memcached) prepend(key string, val string) bool {
	msg := 'prepend $key 0 0 $val.len'
	m.write(msg) or { return false }
	m.write('$val') or { return false }
	response := m.read() or { return false }
	return match response {
		'STORED' { true }
		else { false }
	}
}

// TODO: use optional typing
pub fn (m Memcached) gets(key string) Value {
	m.write('gets $key') or { return Value{} }
	response := m.read_multi() or { return Value{} }
	if response[0] == 'END' {
		return Value{}
	}
	response_params := response[0].split(' ')
	casid := response_params[response_params.len - 1]
	value := response[1]
	return Value{value, casid}
}

pub fn (m Memcached) cas(key string, val string, exp int, casid int) bool {
	m.write('cas $key 0 $exp $val.len $casid') or { return false }
	m.write('$val') or { return false }
	response := m.read() or { return false }
	return match response {
		'STORED' { true }
		else { false }
	}
}
