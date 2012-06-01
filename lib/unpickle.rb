# unpickle.rb
# 
# baby-unpickler to handle limited protocol 0 crap.
#
# vim:et sts=4 sw=4 ts=8:
#
module Unpickle
    class UnpickleException < RuntimeError
    end

    class Mark
    end

    class PickleMachine
        def initialize(input)
            @stack = []
            @memo = {}
            @input = input
            @idx = 0
        end

        def at_end?
            @idx >= @input.length
        end

        def next_char
            rv = @input[@idx..@idx]
            @idx += 1
            return rv
        end

        def peek_char
            @input[@idx..@idx]
        end

        def read_int
            strout = ""
            while peek_char != "\n"
                strout += next_char
            end
            next_char
            case strout
            when '00'
                return false
            when '01'
                return true
            else
                return strout.to_i
            end
        end

        def marker
            idx = @stack.length-1
            while idx >= 0
                if @stack[idx].is_a?(Mark)
                    return idx
                end
                idx -= 1
            end
            raise UnpickleException, "Couldn't find Mark"
        end

        # read from the input stream to read the python string.
        #
        # returns the value.
        def read_string
            strout = ''
            if next_char != '\''
                raise UnpickleException, "Couldn't find leading quote for string"
            end
            while not at_end?
                c = next_char
                case c
                when "\\"
                    opt = next_char
                    case opt
                    when 'x'
                        num = ''
                        while peek_char.match(/[\dA-Fa-f]/)
                            num += next_char
                            if num.length >= 2
                                break
                            end
                        end
                        unless (1..2).include?(num.length)
                            raise UnpickleException, "Bad \\x sequence in string"
                        end
                        strout += num.to_i(16).chr
                    when '0'
                        num = ''
                        while peek_char.match(/[0-7]/)
                            num += next_char
                            if num.length >= 3
                                break
                            end
                        end
                        unless (1..3).include?(num.length)
                            raise UnpickleException, "Bad \\0 sequence in string"
                        end
                        strout += num.to_i(8).chr
                    when 'n'
                        strout += "\n"
                    when "\\"
                        strout += "\\"
                    when 't'
                        strout += "\t"
                    when "'"
                        strout += "'"
                    else
                        raise UnpickleException, "Unexpected \\ escape: \\#{opt}"
                    end
                when "'"
                    # valid end of string...
                    break
                else
                    strout += c
                end
            end
            if next_char != "\n"
                raise UnpickleException, "Expected \\n after string"
            end
            return strout
        end

        def unpickle
            while not at_end?
                op = next_char
                case op
                when '(' # MARK
                    @stack.push(Mark.new)
                when 'd' # DICT
                    newdict = {}
                    while true
                        if @stack.empty?
                            raise UnpickleException, "Stack empty during 'd'"
                        end
                        v = @stack.pop
                        if v.is_a?(Mark)
                            break
                        end
                        if @stack.empty?
                            raise UnpickleException, "Stack empty during 'd'"
                        end
                        k = stack.pop
                        if k.is_a?(Mark)
                            raise UnpickleException, "Odd number of elements during 'd' stack walk"
                        end
                        newdict[k] = v
                    end
                    @stack.push(newdict)
                when 'S' # STRING
                    newstr = read_string
                    @stack.push(newstr)
                when 'p' # PUT (string)
                    index = read_int
                    @memo[index] = @stack[-1]
                when 'g' # GET (string)
                    index = read_int
                    @stack.push(@memo[index])
                when 'I' # INT
                    intarg = read_int
                    @stack.push(intarg)
                when 's' # SETITEM
                    value = @stack.pop
                    key = @stack.pop
                    dict = @stack[-1]
                    dict[key] = value
                when 't' # TUPLE
                    midx = marker
                    tuple = @stack[midx+1..-1]
                    @stack = @stack[0...midx]
                    tuple.freeze
                    @stack.push(tuple)
                when 'l' # LIST
                    midx = marker
                    list = @stack[midx+1..-1]
                    @stack = @stack[0...midx]
                    @stack.push(list)
                when 'N' # NONE
                    @stack.push(nil)
                when 'a' # APPEND
                    e = @stack.pop
                    @stack[-1].push(e)
                when '0' # POP
                    @stack.pop
                when '2' # DUP
                    @stack.push(@stack[-1])
                when '.' # STOP
                    return @stack.pop
                else
                    raise UnpickleException, "Unsupported unpickle operation '#{op}'"
                end
            end
            raise UnpickleException, "Hit end of input stream"
        end
    end

    # Unpickle the python object pickled into str.
    # 
    # At this time, this ONLY works with a limited set of constructs 
    # (dicts, lists, tuples, strings, ints, bools, None) and only with
    # protocol 0.
    # 
    # Object uniqueness should obey the python semantics but is largely 
    # untested.
    #
    # Raises an UnpickleException if anything goes wrong.
    def Unpickle.loads(str)
        p = Unpickle::PickleMachine.new(str)
        return p.unpickle
    end
end

