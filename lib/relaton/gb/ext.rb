require_relative "doctype"
require_relative "committee"
require_relative "structured_identifier"
require_relative "stage_name"
require_relative "gb_type"
require_relative "ccs"

module Relaton
  module Gb
    class Ext < Bib::Ext
      attribute :doctype, Doctype
      attribute :subdoctype, :string, values: %w[specification method-of-test vocabulary code-of-practice]
      attribute :structuredidentifier, StructuredIdentifier
      attribute :stagename, StageName
      attribute :gbtype, GbType
      attribute :ccs, CCS, collection: true
      attribute :plannumber, :string

      xml do
        map_element "stagename", to: :stagename
        map_element "gbtype", to: :gbtype
        map_element "ccs", to: :ccs
        map_element "plannumber", to: :plannumber
      end

      key_value do
        map_element "stagename", to: :stagename
        map_element "gbtype", to: :gbtype
        map_element "ccs", to: :ccs
        map_element "plannumber", to: :plannumber
      end

      def get_schema_version = Relaton.schema_versions["relaton-model-gb"]
    end
  end
end
