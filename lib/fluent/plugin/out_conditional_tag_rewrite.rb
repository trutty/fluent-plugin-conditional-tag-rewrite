# frozen_string_literal: true

#
# Copyright 2021- Christian Schulz
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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
