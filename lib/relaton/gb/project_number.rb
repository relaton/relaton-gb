module Relaton
  module Gb
    class ProjectNumber < Lutaml::Model::Serializable
      attribute :part, :integer
      attribute :subpart, :integer
      attribute :amendment, :integer
      attribute :corrigendum, :integer
      attribute :origyr, :string
      attribute :content, :string

      xml do
        root "project-ntnumber"
        map_attribute "part", to: :part
        map_attribute "subpart", to: :subpart
        map_attribute "amendment", to: :amendment
        map_attribute "corrigendum", to: :corrigendum
        map_attribute "origyr", to: :origyr
        map_content to: :content
      end

      def to_all_parts!
        remove_part!
        remove_date!
      end

      def remove_part!
        self.part = nil
        self.subpart = nil
        self.amendment = nil
        self.corrigendum = nil
      end

      def remove_date!
        self.origyr = nil
      end
    end
  end
end
