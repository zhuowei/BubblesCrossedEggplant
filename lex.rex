class Lex
macro
rule
	\s+ # whitespace
	\(	{ [:OPEN_PAREN, nil] }
	\)	{ [:CLOSE_PAREN, nil] }
	\'	{ [:QUOTE, nil] }
	[+\-]?[0-9]+ { [:NUMBER, text.to_i] }
	[a-zA-Z+\-\*\/\?_][a-zA-Z0-9+\-\*\/\?_]* { [:SYMBOL, text] }
	.	{ p "FAIL!" }
end