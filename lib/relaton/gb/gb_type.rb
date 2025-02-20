module Relaton
  module Gb
    class GbType < Lutaml::Model::Serializable
      attribute :gbscope, :string, values: %w[national sector professional local enterprise social-group]
      attribute :gbprefix, :string
      attribute :gbmandate, :string, values: %w[mandatory recommended guidelines]
      attribute :gbtopic, :string, values: %w[
        basic health-and-safety environment-protection engineering-and-construction
        product method management-techniques other
      ]

      xml do
        map_element "gbscope", to: :gbscope
        map_element "gbprefix", to: :gbprefix
        map_element "gbmandate", to: :gbmandate
        map_element "gbtopic", to: :gbtopic
      end
    end
  end
end
