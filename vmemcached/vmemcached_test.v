import vmemcached

fn setup() vmemcached.Memcached {
	m := vmemcached.connect(vmemcached.Connection{}) or {
		panic(err)
	}
	return m
}

fn clean(m vmemcached.Memcached) {
	m.flushall()
	m.disconnect()
}

fn test_flushall() {
	m := setup()
	defer {
		clean(m)
	}
	response := m.flushall()
	assert response == true
}

fn test_empty_get() {
	m := setup()
	defer {
		clean(m)
	}
	response := m.get('test')
	assert response.content == ''
}

fn test_set_value() {
	m := setup()
	defer {
		clean(m)
	}
	response := m.set('key', 'value')
	assert response == true
}

fn test_nonempty_get() {
	m := setup()
	defer {
		clean(m)
	}
	m.set('key', 'test')
	response := m.get('key')
	assert response.content == 'test'
}
