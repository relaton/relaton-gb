# frozen_string_literal: true

# GB bib module.
module Gbbib
  # GB entry point class.
  class GbBibliography
    class << self
      # rubocop:disable Metrics/MethodLength
      # @param text [Strin] code of standard for search
      # @return [Gbbib::Hits]
      def search(text)
        if text.match?(/^(GB|GJ|GS)/)
          # Scrape national standards.
          require 'gbbib/gb_scrapper'
          GbScrapper.scrape_page text
        elsif text.match?(/^ZB/)
          # Scrape proffesional.
        elsif text.match?(/^DB/)
          # Scrape local standard.
        elsif text.match? %r{^Q\/}
          # Enterprise standard
        elsif text.match? %r{^T\/[^\s]{3,6}\s}
          # Scrape social standard.
          require 'gbbib/t_scrapper'
          TScrapper.scrape_page text
        else
          # Scrape sector standard.
          require 'gbbib/sec_scrapper'
          SecScrapper.scrape_page text
        end
      end
      # rubocop:enable Metrics/MethodLength
    end
  end
end
