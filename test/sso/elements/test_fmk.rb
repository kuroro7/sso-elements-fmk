# frozen_string_literal: true

require_relative "../../test_helper"

class SSO::Elements::TestFmk < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::SSO::Elements::Fmk::VERSION
  end
end
