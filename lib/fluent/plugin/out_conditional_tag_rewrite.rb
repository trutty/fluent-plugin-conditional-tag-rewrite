# frozen_string_literal: true

# Copyright (c) 2021- Christian Schulz
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'fluent/plugin/output'
require 'fluent/plugin/string_util'

module Fluent
  module Plugin
    # Plugin '@type conditional_tag_rewrite'
    class ConditionalTagRewriteOutput < Output
      Fluent::Plugin.register_output('conditional_tag_rewrite', self)

      helpers :event_emitter, :record_accessor

      desc 'Default tag to use if no condition matches'
      config_param :fallback_tag, :string, default: nil
      config_section :and, param_name: :ands, multi: true do
        desc 'New tag which will be used to emit matching records'
        config_param :tag, :string
        config_section :condition, param_name: :conditions, multi: true do
          desc 'The field name to which the regular expression is applied'
          config_param :key, :string
          desc 'The regular expression'
          config_param :pattern, :regexp
        end
      end

      def initialize
        super

        @router = router
        @and_conditions = []
      end

      def configure(conf)
        super

        # create objects from configuration
        @ands.each do |and_condition|
          condition_list = and_condition.conditions.map { |c| Condition.new(record_accessor_create(c.key), c.pattern) }
          @and_conditions.append(And.new(and_condition.tag, condition_list))
        end
      end

      def process(tag, es)
        multi_event_streams = Hash.new { |hash, key| hash[key] = MultiEventStream.new }

        es.each do |time, record|
          should_rewrite, rewritten_tag = rewrite?(record)
          multi_event_streams[rewritten_tag].add(time, record) if should_rewrite
        end

        # re-emit all event streams / records with rewritten tags
        multi_event_streams.each do |rewritten_tag, event_stream|
          @router.emit_stream(rewritten_tag, event_stream)
        end
      end

      def rewrite?(record)
        @and_conditions.each do |and_condition|
          next unless and_condition.match?(record)

          return true, and_condition.tag
        end

        [!@fallback_tag.nil?, @fallback_tag]
      end
    end

    Condition = Struct.new(:record_accessor, :pattern) do
      def match?(record)
        StringUtil.match_regexp(pattern, record_accessor.call(record).to_s)
      end
    end

    And = Struct.new(:tag, :conditions) do
      def match?(record)
        conditions.all? { |condition| condition.match?(record) }
      end
    end
  end
end
