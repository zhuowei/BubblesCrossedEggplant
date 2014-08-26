require_relative "lex.rex"
require_relative "stdlib"

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

class Lamb
	attr_accessor :arg_names
	attr_accessor :code
	attr_accessor :scope # TODO
	def call(env, args)
		newenv = env.clone # TODO
		lamb_args_iter(env, args, arg_names) { |arg, name|
			newenv[name.name] = arg
		}
		# todo args
		retval = nil
		args_iter(newenv, code) { |arg|
			retval = arg
		}
		return retval
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
	when :QUOTE
		subtree = parse_impl(lexer)
		node = Node.new
		node.car = Sym.new
		node.car.name = "quote"
		append(node, subtree)
		return node
	end
end

def eval(env, exp)
	if exp.is_a? Numeric
		return exp
	elsif exp.is_a? Sym
		return env[exp.name]
	elsif exp.is_a? Node
		method = eval(env, exp.car)
		if method.is_a? Method or method.is_a? Lamb
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

def lamb_args_iter(env, node, node2)
	while node != nil and node2 != nil
		yield eval(env, node.car), node2.car
		node = node.cdr
		node2 = node2.cdr
	end
end


def define(env, arg)
	name = arg.car.name
	val = eval(env, arg.cdr.car)
	env[name] = val
end

input = gets.strip
if input.length < 1
	#input = "(define x 5)(define y 7)(+ x (- y 1))"
	input = "(define bzzt (lambda (x) (display x) (bzzt (+ x 1))))(bzzt 0)"
end

trees = parse(input)
#p trees

#p "eval"

myenv = {}
init_env(myenv)
trees.each { |tree|
	p eval(myenv, tree)
}