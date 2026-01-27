# frozen_string_literal: true

require "relaton/core/processor"

module Relaton
  module Gb
    class Processor < Relaton::Core::Processor
      def initialize
        @short = :relaton_gb
        @prefix = "CN"
        @defaultprefix = %r{^(GB|GB/T|GB/Z) }
        @idtype = "Chinese Standard"
      end

      # @param code [String]
      # @param date [String, NilClass] year
      # @param opts [Hash]
      # @return [Relaton::Gb::ItemData, nil]
      def get(code, date, opts)
        require_relative "../gb"
        Bibliography.get(code, date, opts)
      end

      # @param xml [String]
      # @return [Relaton::Gb::ItemData]
      def from_xml(xml)
        require_relative "../gb"
        Item.from_xml xml
      end

      # @param yaml [String]
      # @return [Relaton::Gb::ItemData]
      def from_yaml(yaml)
        Item.from_yaml yaml
      end

      # Returns hash of XML grammar
      # @return [String]
      def grammar_hash
        require_relative "../gb"
        @grammar_hash ||= ::Relaton::Gb.grammar_hash
      end
    end
  end
end
