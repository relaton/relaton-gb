require_relative "doctype"
require_relative "committee"
require_relative "stage_name"
require_relative "gb_type"

module Relaton
  module Gb
    class Ext < Lutaml::Model::Serializable
      attribute :schema_version, :string
      attribute :doctype, Doctype
      attribute :subdoctype, :string, values: %w[specification method-of-test vocabulary code-of-practice]
      attribute :gbcommittee, Committee, collection: true
      attribute :ics, Bib::ICS, collection: true
      attribute :structuredidentifier, Iso::StructuredIdentifier
      attribute :stagename, StageName
      attribute :gbtype, GbType
      attribute :ccs, Bib::ICS, collection: true
      attribute :plannumber, :string

      xml do
        map_attribute "schema-version", to: :schema_version
        map_element "doctype", to: :doctype
        map_element "subdoctype", to: :subdoctype
        map_element "gbcommittee", to: :gbcommittee
        map_element "ics", to: :ics
        map_element "structuredidentifier", to: :structuredidentifier
        map_element "stagename", to: :stagename
        map_element "gbtype", to: :gbtype
        map_element "ccs", to: :ccs
        map_element "plannumber", to: :plannumber
      end
    end
  end
end
