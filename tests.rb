# tests for unpickle.rb
#
# vim:et sts=4 sw=4 ts=8:
require 'test/unit'
require 'unpickle'

class UnpickleTests < Test::Unit::TestCase
    # all pickle_str's were generated using python 2.5
    # and pickle.dumps(...., 0)
    
    def test_simple_string
        # >>> pickle_obj = 'abcdefg'
        pickle_str = "S'abcdefg'\np0\n."

        o = unpickle(pickle_str)

        assert_equal('abcdefg', o)
    end

    def test_simple_bool_true
        # >>> pickle_obj = True
        pickle_str = "I01\n."

        o = unpickle(pickle_str)

        assert_equal(true, o)
    end

    def test_simple_bool_false
        # >>> pickle_obj = False
        pickle_str = "I00\n."

        o = unpickle(pickle_str)

        assert_equal(false, o)
    end

    def test_simple_list
        # >>> pickle_obj = [1,2,3]
        pickle_str = "(lp0\nI1\naI2\naI3\na."

        o = unpickle(pickle_str)

        assert_equal([1,2,3], o)
    end

    def test_simple_dict
        # >>> pickle_obj = {'a': 1, 'b': 2, 'c': 3}
        pickle_str = "(dp0\nS'a'\np1\nI1\nsS'c'\np2\nI3\nsS'b'\np3\nI2\ns."

        o = unpickle(pickle_str)

        assert_equal({'a' => 1, 'b' => 2, 'c' => 3}, o)
    end

    def test_simple_int_zero
        # >>> pickle_obj = 0
        pickle_str = "I0\n."

        o = unpickle(pickle_str)

        assert_equal(0, o)
    end

    def test_none
        # >>> pickle_obj = None
        pickle_str = 'N.'

        o = unpickle(pickle_str)

        assert_equal(nil, o)
    end

    def test_mixed
        # >>> pickle_obj = {'a': [1,2,3,4], 'b': (1,2,3), 'c': None, 'd': 'abcd'}
        pickle_str = "(dp0\nS'a'\np1\n(lp2\nI1\naI2\naI3\naI4\nasS'c'\np3\nNsS'b'\np4\n(I1\nI2\nI3\ntp5\nsS'd'\np6\nS'abcd'\np7\ns."

        o = unpickle(pickle_str)

        assert_equal({'a' => [1,2,3,4], 'b' => [1,2,3], 'c' => nil, 'd' => 'abcd'}, o)
    end

    def test_recursive
        # >>> aobj = {}
        # >>> bobj = {'a': aobj}
        # >>> aobj['b'] = bobj
        # >>> pickle.dumps(aobj, 0)
        pickle_str = "(dp0\nS'b'\np1\n(dp2\nS'a'\np3\ng0\nss."

        o = unpickle(pickle_str)

        assert(o.is_a?(Hash))
        assert(o.include?('b'))
        assert(o['b'].is_a?(Hash))
        assert(o['b'].include?('a'))
        # check that the object identity is correctly respected.
        assert(o.object_id == o['b']['a'].object_id)
    end
end
