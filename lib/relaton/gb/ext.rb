require_relative "doctype"
require_relative "committee"
require_relative "structured_identifier"
require_relative "stage_name"
require_relative "gb_type"
require_relative "ccs"

module Relaton
  module Gb
    class Ext < Lutaml::Model::Serializable
      attribute :schema_version, method: :get_schema_version
      attribute :doctype, Doctype
      attribute :subdoctype, :string, values: %w[specification method-of-test vocabulary code-of-practice]
      # attribute :gbcommittee, Committee, collection: true
      attribute :ics, Bib::ICS, collection: true
      attribute :structuredidentifier, StructuredIdentifier
      attribute :stagename, StageName
      attribute :gbtype, GbType
      attribute :ccs, CCS, collection: true
      attribute :plannumber, :string

      xml do
        map_attribute "schema-version", to: :schema_version
        map_element "doctype", to: :doctype
        map_element "subdoctype", to: :subdoctype
        # map_element "gbcommittee", to: :gbcommittee
        map_element "ics", to: :ics
        map_element "structuredidentifier", to: :structuredidentifier
        map_element "stagename", to: :stagename
        map_element "gbtype", to: :gbtype
        map_element "ccs", to: :ccs
        map_element "plannumber", to: :plannumber
      end

      def get_schema_version
        Relaton.schema_versions["relaton-model-gb"]
      end
    end
  end
end
