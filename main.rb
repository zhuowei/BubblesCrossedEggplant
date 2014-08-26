require_relative "lex.rex"

class Sym
	attr_accessor :name
	def to_s
		return name
	end
end

class Node
	attr_accessor :car
	attr_accessor :cdr
	def to_s
		s = "("
		t = self
		while t != nil
			s += t.car.to_s
			s += " "
			t = t.cdr
		end
		s += ")"
		return s
	end
end

def parse(s)
	lexer = Lex.new
	lexer.scan_setup s
	allparts = []
	while (part = parse_impl(lexer)) != nil
		allparts.push part
	end
	return allparts
end

def append(c, val)
	#p c, val
	if c == nil
		c = Node.new
	end
	if c.car == nil
		c.car = val
		return c
	end
	n = Node.new
	n.car = val
	c.cdr = n
	return n
end

def parse_impl(lexer)
	tok = lexer.next_token
	if tok == nil
		return nil
	end
	#p tok
	case tok[0]
	when :CLOSE_PAREN
		return nil
	when :OPEN_PAREN
		tree = Node.new
		c = tree
		while (inside = parse_impl(lexer)) != nil
			#p "inside:" + inside.to_s
			c = append(c, inside)
		end
		#p "retval: " + tree.to_s
		if tree.car == nil
			return nil
		end
		return tree
	when :NUMBER
		return tok[1]
	when :SYMBOL
		sym = Sym.new
		sym.name = tok[1]
		return sym
	end
end

def eval(env, exp)
	if exp.is_a? Numeric
		return exp
	elsif exp.is_a? Sym
		return env[exp.name]
	elsif exp.is_a? Node
		method = eval(env, exp.car)
		if method.is_a? Method
			return method.call(env, exp.cdr)
		else
			p "todo"
			return nil
		end
	else
		p "wat" + exp.to_s
	end
end

def args_iter(env, node)
	while node != nil
		yield eval(env, node.car)
		node = node.cdr
	end
end

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

def define(env, arg)
	name = arg.car.name
	val = eval(env, arg.cdr.car)
	env[name] = val
end

input = gets.strip
if input.length < 1
	input = "(define x 5)(define y 7)(+ x (- y 1))"
end

trees = parse(input)
#p trees

#p "eval"

myenv = {"+" => method(:add), "-" => method(:sub), "*" => method(:mul), "/" => method(:div), "define" => method(:define)}
trees.each { |tree|
	p eval(myenv, tree)
}