module Relaton
  module Gb
    class Committee < Lutaml::Model::Serializable
      attribute :type, :string, values: %w[technical provisional drafting]
      attribute :content, :string

      xml do
        map_attribute "type", to: :type
        map_content to: :content
      end
    end
  end
end
