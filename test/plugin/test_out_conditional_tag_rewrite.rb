# frozen_string_literal: true

require_relative '../helper'
require 'fluent/plugin/out_conditional_tag_rewrite'

class ConditionalTagRewriteOutputTest < Test::Unit::TestCase
  setup do
    Fluent::Test.setup
  end

  test "failure" do
    flunk
  end

  private

  def create_driver(conf)
    Fluent::Test::Driver::Output.new(Fluent::Plugin::ConditionalTagRewriteOutput).configure(conf)
  end
end
