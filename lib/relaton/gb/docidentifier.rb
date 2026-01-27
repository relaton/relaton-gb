module Relaton
  module Gb
    class Docidentifier < Bib::Docidentifier
      def content
        @all_parts ? "#{super} (all parts)" : super
      end

      def to_all_parts!
        remove_part!
        remove_date!
        @all_parts = true
      end

      def remove_part!
        content.sub!(/\.\d+/, "")
      end

      def remove_date!
        content.sub!(/-\d{4}$/, "")
      end
    end
  end
end
