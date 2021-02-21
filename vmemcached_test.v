module vmemcached

fn setup() Memcached {
	mut m := connect(Connection{}) or { panic(err) }
	return m
}

fn clean(mut m Memcached) {
	m.flushall()
	m.disconnect()
}

fn test_flushall() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	response := m.flushall()
	assert response
}

fn test_empty_get() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	response := m.get('test')
	assert response.content == ''
}

fn test_set_value() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	response := m.set('key', 'value', 0)
	assert response
}

fn test_nonempty_get() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	m.set('key', 'test', 0)
	response := m.get('key')
	assert response.content == 'test'
}

fn test_replace_empty_key() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	response := m.replace('key', 'test', 0)
	assert !response
}

fn test_replace_work_with_real_key() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	m.set('key', '1', 0)
	response := m.replace('key', '2', 0)
	assert response
	real_val := m.get('key')
	assert real_val.content == '2'
}

fn test_delete_empty_key() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	response := m.delete('key')
	assert !response
}

fn test_delete_with_real_key() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	m.set('key', '1', 0)
	response := m.delete('key')
	assert response
}

fn test_add_work_with_empty_key() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	response := m.add('key', '1', 0)
	assert response
}

fn test_add_do_not_work_with_nonempty_key() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	m.set('key', '1', 0)
	response := m.add('key', '2', 0)
	assert !response
}

fn test_incr_do_not_work_with_empty_value() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	response := m.incr('key', '1')
	assert !response
}

fn test_incr_just_work() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	m.set('key', '1', 0)
	response := m.incr('key', '1')
	assert response
	val := m.get('key')
	assert val.content == '2'
}

fn test_decr_do_not_work_with_empty_key() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	response := m.decr('key', '1')
	assert !response
}

fn test_decr_just_work() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	m.set('key', '2', 0)
	response := m.decr('key', '1')
	assert response
	val := m.get('key')
	assert val.content == '1'
}

fn test_touch_do_not_work_with_unexists_key() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	response := m.touch('key', 0)
	assert !response
}

fn test_touch_success_case() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	m.set('test', '1', 0)
	response := m.touch('test', 0)
	assert response
}

fn test_append_do_not_work_with_unexists_key() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	response := m.append('test', '1')
	assert !response
}

fn test_append_work() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	m.set('test', '1', 0)
	m.append('test', '2')
	response := m.get('test')
	assert response.content == '12'
}

fn test_prepend_do_not_work_with_unexists_key() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	response := m.prepend('test', '1')
	assert !response
}

fn test_prepend_work() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	m.set('test', '1', 0)
	m.prepend('test', '2')
	response := m.get('test')
	assert response.content == '21'
}

fn test_gets_return_uniq() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	m.set('test', '1', 0)
	response := m.gets('test')
	assert response.content == '1'
	assert response.casid != ''
}

fn test_cas_do_not_work_with_unexists_key() {
	mut m := setup()
	defer {
		clean(mut m)
	}
	response := m.cas('test', '1', 0, 1)
	assert !response
}
