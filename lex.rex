class Lex
macro
rule
	;;.*$ {}
	"[^"]*" { [:STRING_LITERAL, text] }
	\s+ # whitespace
	\(	{ [:OPEN_PAREN, nil] }
	\)	{ [:CLOSE_PAREN, nil] }
	\'	{ [:QUOTE, nil] }
	[+\-]?[0-9]+ { [:NUMBER, text.to_i] }
	\#[tf]	{ [:BOOLEAN_LITERAL, text[1] == "t"? true: false] }
	[a-zA-Z+\-\*\/\?!\.$%&:<=>~\^_][a-zA-Z0-9+\-\*\/\?!\.$%&:<=>~\^_]* { [:SYMBOL, text] }
	.	{ p "FAIL!" + text }
end