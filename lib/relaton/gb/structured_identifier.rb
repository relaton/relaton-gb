require_relative "project_number"

module Relaton
  module Gb
    class StructuredIdentifier < Lutaml::Model::Serializable
      attribute :type, :string
      attribute :project_number, ProjectNumber
      attribute :tc_document_number, :integer

      xml do
        root "structuredidentifier"
        map_attribute "type", to: :type
        map_element "project-number", to: :project_number
        map_element "tc-document-number", to: :tc_document_number
      end

      def to_all_parts!
        project_number&.to_all_parts!
      end

      def remove_date!
        project_number&.remove_date!
      end
    end
  end
end
