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

def if(env, arg)
	cond = eval(env, arg.car)
	arg = arg.cdr
	first = arg.car
	arg = arg.cdr
	second = nil
	if arg != nil
		second = arg.car
	end
	if cond
		if first != nil
			return eval(env, first)
		end
	else
		if second != nil
			return eval(env, second)
		end
	end
	return nil
end

def eq(env, arg)
	first = eval(env, arg.car)
	args_iter(env, arg.cdr) { |val|
		if val != first
			return false
		end
	}
	return true
end

def init_env(env)
	myenv = {"+" => method(:add), "-" => method(:sub), "*" => method(:mul), "/" => method(:div), "define" => method(:define),
		"quote" => method(:quote),
		"lambda" => method(:lamb),
		"display" => method(:display),
		"if" => method(:if),
		"eq?" => method(:eq),
		"nil" => nil,
	}
	env.merge! myenv
end