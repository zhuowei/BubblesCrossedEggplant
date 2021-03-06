#--
# DO NOT MODIFY!!!!
# This file is automatically generated by rex 1.0.5
# from lexical definition file "lex.rex".
#++

class Lex
  require 'strscan'

  class ScanError < StandardError ; end

  attr_reader   :lineno
  attr_reader   :filename
  attr_accessor :state

  def scan_setup(str)
    @ss = StringScanner.new(str)
    @lineno =  1
    @state  = nil
  end

  def action
    yield
  end

  def scan_str(str)
    scan_setup(str)
    do_parse
  end
  alias :scan :scan_str

  def load_file( filename )
    @filename = filename
    open(filename, "r") do |f|
      scan_setup(f.read)
    end
  end

  def scan_file( filename )
    load_file(filename)
    do_parse
  end


  def next_token
    return if @ss.eos?
    
    # skips empty actions
    until token = _next_token or @ss.eos?; end
    token
  end

  def _next_token
    text = @ss.peek(1)
    @lineno  +=  1  if text == "\n"
    token = case @state
    when nil
      case
      when (text = @ss.scan(/;;.*$/))
         action {}

      when (text = @ss.scan(/"[^"]*"/))
         action { [:STRING_LITERAL, text] }

      when (text = @ss.scan(/\s+/))
        ;

      when (text = @ss.scan(/\(/))
         action { [:OPEN_PAREN, nil] }

      when (text = @ss.scan(/\)/))
         action { [:CLOSE_PAREN, nil] }

      when (text = @ss.scan(/\'/))
         action { [:QUOTE, nil] }

      when (text = @ss.scan(/[+\-]?[0-9]+/))
         action { [:NUMBER, text.to_i] }

      when (text = @ss.scan(/\#[tf]/))
         action { [:BOOLEAN_LITERAL, text[1] == "t"? true: false] }

      when (text = @ss.scan(/[a-zA-Z+\-\*\/\?!\.$%&:<=>~\^_][a-zA-Z0-9+\-\*\/\?!\.$%&:<=>~\^_]*/))
         action { [:SYMBOL, text] }

      when (text = @ss.scan(/./))
         action { p "FAIL!" + text }

      else
        text = @ss.string[@ss.pos .. -1]
        raise  ScanError, "can not match: '" + text + "'"
      end  # if

    else
      raise  ScanError, "undefined state: '" + state.to_s + "'"
    end  # case state
    token
  end  # def _next_token

end # class
