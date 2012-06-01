# unpickle

This is a very limited tool to unpickle python 'pickle' objects.

# Usage

    require 'unpickle'
    
    fh = File.open('some.pickle')
    o = Unpickle.loads(fh.read)

loads() will raise Unpickle::UnpickleException if it doesn't support an
opcode in the picklestream, or encounters some kind of problem or invalid 
sequence.

# Limitations

Currently unpickle only supports protocol 0.

It only supports Integers (not Longs), Strings (non-unicode),
booleans, dictionaries, lists, tuples and None.

Tuples will be returned as a frozen array.

None will be returned as nil.

# TODO

 * Support more of protocol 0.
 * Support newer protocols.

# Author

Chris Collins <chris.collins@anchor.net.au>
