module Relaton
  module Gb
    class StageName < Lutaml::Model::Serializable
      attribute :abbreviation, :string
      attribute :content, :string

      xml do
        map_attribute "abbreviation", to: :abbreviation
        map_content to: :content
      end
    end
  end
end
