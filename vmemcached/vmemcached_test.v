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
	assert response
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
	assert response
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

fn test_replace_empty_key() {
	m := setup()
	defer {
		clean(m)
	}
	response := m.replace('key', 'test')
	assert !response
}

fn test_replace_work_with_real_key() {
	m := setup()
	defer {
		clean(m)
	}
	m.set('key', '1')
	response := m.replace('key', '2')
	assert response
	real_val := m.get('key')
	assert real_val.content == '2'
}

fn test_delete_empty_key() {
	m := setup()
	defer {
		clean(m)
	}
	response := m.delete('key')
	assert !response
}

fn test_delete_with_real_key() {
	m := setup()
	defer {
		clean(m)
	}
	m.set('key', '1')
	response := m.delete('key')
	assert response
}

fn test_add_work_with_empty_key() {
	m := setup()
	defer {
		clean(m)
	}
	response := m.add('key', '1')
	assert response
}

fn test_add_do_not_work_with_nonempty_key() {
	m := setup()
	defer {
		clean(m)
	}
	m.set('key', '1')
	response := m.add('key', '2')
	assert !response
}

fn test_incr_do_not_work_with_empty_value() {
	m := setup()
	defer {
		clean(m)
	}
	response := m.incr('key', '1')
	assert !response
}

fn test_incr_just_work() {
	m := setup()
	defer {
		clean(m)
	}
	m.set('key', '1')
	response := m.incr('key', '1')
	assert response
	val := m.get('key')
	assert val.content == '2'
}
