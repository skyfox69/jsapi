# frozen_string_literal: true

module Jsapi
  module Model
    class ExistenceTest < Minitest::Test
      def test_allow_omitted
        assert_equal(Existence::ALLOW_OMITTED, Existence.from(:allow_omitted))
      end

      def test_allow_nil
        assert_equal(Existence::ALLOW_NIL, Existence.from(:allow_nil))
      end

      def test_allow_empty
        assert_equal(Existence::ALLOW_EMPTY, Existence.from(:allow_empty))
      end

      def test_present
        assert_equal(Existence::PRESENT, Existence.from(:present))
      end

      def test_from_true
        assert_equal(Existence::PRESENT, Existence.from(true))
      end

      def test_from_false
        assert_equal(Existence::ALLOW_OMITTED, Existence.from(false))
      end

      def test_from_existence
        assert_equal(Existence::PRESENT, Existence.from(Existence::PRESENT))
      end

      def test_invalid_existence
        error = assert_raises(ArgumentError) { Existence.from('foo') }
        assert_equal('invalid existence: foo', error.message)
      end

      def test_present_is_greater_than_allow_empty
        assert(Existence::PRESENT > Existence::ALLOW_EMPTY)
      end

      def test_allow_empty_is_greater_than_allow_nil
        assert(Existence::PRESENT > Existence::ALLOW_EMPTY)
      end

      def test_allow_nil_is_greater_than_allow_ommitted
        assert(Existence::PRESENT > Existence::ALLOW_EMPTY)
      end
    end
  end
end
