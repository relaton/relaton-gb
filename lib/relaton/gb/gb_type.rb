module Relaton
  module Gb
    class GbType < Lutaml::Model::Serializable
      attribute :scope, :string, values: %w[national sector professional local enterprise social-group]
      attribute :prefix, :string
      attribute :mandate, :string, values: %w[mandatory recommended guidelines]
      attribute :topic, :string, values: %w[
        basic health-and-safety environment-protection engineering-and-construction
        product method management-techniques other
      ]

      xml do
        map_element "gbscope", to: :scope
        map_element "gbprefix", to: :prefix
        map_element "gbmandate", to: :mandate
        map_element "gbtopic", to: :topic
      end
    end
  end
end
