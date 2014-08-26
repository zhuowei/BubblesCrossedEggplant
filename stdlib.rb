def add(env, arg)
	ret = 0
	args_iter(env, arg) { |val|
		ret += val
	}
	return ret
end

def sub(env, arg)
	ret = eval(env, arg.car)
	args_iter(env, arg.cdr) { |val|
		ret -= val
	}
	return ret
end

def mul(env, arg)
	ret = 1
	args_iter(env, arg) { |val|
		ret *= val
	}
	return ret
end

def div(env, arg)
	ret = eval(env, arg.car)
	args_iter(env, arg.cdr) { |val|
		ret /= val
	}
	return ret
end

def quote(env, arg)
	return arg.car
end

def lamb(env, arg)
	lamb = Lamb.new
	lamb.arg_names = arg.car
	lamb.code = arg.cdr
	return lamb
end

def display(env, arg)
	val = eval(env, arg.car)
	p val
end

def init_env(env)
	myenv = {"+" => method(:add), "-" => method(:sub), "*" => method(:mul), "/" => method(:div), "define" => method(:define),
		"quote" => method(:quote),
		"lambda" => method(:lamb),
		"display" => method(:display),
	}
	env.merge! myenv
end