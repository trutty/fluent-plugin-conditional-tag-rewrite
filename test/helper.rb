# frozen_string_literal: true

$LOAD_PATH.unshift(File.expand_path('../../', __FILE__))
$LOAD_PATH.unshift(File.join(__dir__, '..', 'fluentd', 'lib'))
require 'test-unit'
require 'fluent/test'
require 'fluent/test/driver/output'
require 'fluent/test/helpers'

Test::Unit::TestCase.include(Fluent::Test::Helpers)
