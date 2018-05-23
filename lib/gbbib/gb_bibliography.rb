# GB bib module.
module Gbbib
  # GB entry point class.
  class GbBibliography
    class << self
      def search(text)
        if text =~ /^(GB|GJ|GS)/
          # Scrape national standards.
          require 'gbbib/gb_scrapper'
          GbScrapper.scrape_page text
        elsif text =~ /^ZB/
          # Scrape proffesional.
        elsif text =~ /^DB/
          # Scrape local standard.
        elsif text =~ %r{^Q\/}
          # Enterprise standard
        elsif text =~ %r{^T\/[^\s]{3,6}\s}
          # Scrape social standard.
          require 'gbbib/t_scrapper'
          TScrapper.scrape_page text
        else
          # Scrape sector standard.
          require 'gbbib/sec_scrapper'
          SecScrape.scrape_page text
        end
      end
    end
  end
end
