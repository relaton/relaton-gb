# frozen_string_literal: true

require "relaton_gb/gb_bibliographic_item"
require "relaton_gb/gb_standard_type"
require "relaton_gb/hit_collection"
require "relaton_gb/hit"

# GB bib module.
module RelatonGb
  # GB entry point class.
  class GbBibliography
    class << self
      # rubocop:disable Metrics/MethodLength
      # @param text [Strin] code of standard for search
      # @return [RelatonGb::HitCollection]
      def search(text)
        case text
        when /^(GB|GJ|GS)/
          # Scrape national standards.
          Util.info "Fetching from openstd.samr.gov.cn ...", key: text
          require "relaton_gb/gb_scrapper"
          GbScrapper.scrape_page text
        # when /^ZB/
          # Scrape proffesional.
        # when /^DB/
          # Scrape local standard.
        # when %r{^Q/}
          # Enterprise standard
        when %r{^T/[^\s]{2,6}\s}
          # Scrape social standard.
          Util.info "Fetching from www.ttbz.org.cn ...", key: text
          require "relaton_gb/t_scrapper"
          TScrapper.scrape_page text
        else
          # Scrape sector standard.
          # require "relaton_gb/sec_scrapper"
          # SecScrapper.scrape_page text
          []
        end
      end
      # rubocop:enable Metrics/MethodLength

      # @param code [String] the GB standard Code to look up (e..g "GB/T 20223")
      # @param year [String] the year the standard was published (optional)
      # @param opts [Hash] options; restricted to :all_parts if all-parts reference is required
      # @return [String] Relaton XML serialisation of reference
      def get(code, year = nil, opts = {}) # rubocop:disable Metrics/CyclomaticComplexity,Metrics/MethodLength,Metrics/PerceivedComplexity
        if year.nil?
          /^(?<code1>[^-]+)-(?<year1>[^-]+)$/ =~ code
          unless code1.nil?
            code = code1
            year = year1
          end
        end

        code += ".1" if opts[:all_parts]
        code, year = code.split("-", 2) if code.include?("-")
        ret = get1(code, year, opts)
        return nil if ret.nil?

        ret = ret.to_most_recent_reference unless year
        ret = ret.to_all_parts if opts[:all_parts]
        ret
      end

      private

      def fetch_ref_err(code, year, missed_years) # rubocop:disable Metrics/MethodLength
        # id = year ? "#{code}:#{year}" : code
        # Util.info "WARNING: No match found on the GB website for `#{id}`. " \
        #           "The code must be exactly like it is on the website."
        unless missed_years.empty?
          Util.info "(There was no match for `#{year}`, though there " \
                    "were matches found for `#{missed_years.join('`, `')}`.)"
        end
        if /\d-\d/.match? code
          Util.info "The provided document part may not exist, or " \
                    "the document may no longer be published in parts."
        else
          Util.info "If you wanted to cite all document parts for the " \
                    "reference, use `#{code} (all parts)`.\nIf the document " \
                    "is not a standard, use its document type abbreviation " \
                    "(TS, TR, PAS, Guide)."
        end
        nil
      end

      def get1(code, year, _opts)
        # search must include year whenever available
        searchcode = code + (year.nil? ? "" : "-#{year}")
        result = search_filter(searchcode) || return
        ret = results_filter(result, year)
        if ret[:ret]
          Util.info "Found: `#{ret[:ret].docidentifier.first.id}`", key: searchcode
          ret[:ret]
        else
          Util.info "Not found.", key: searchcode
          fetch_ref_err(code, year, ret[:years])
        end
      end

      def search_filter(code)
        # search filter needs to incorporate year
        docidrx = %r{^[^\s]+\s[\d.-]+}
        result = search(code)
        result.select do |hit|
          hit.docref && hit.docref.match(docidrx).to_s.include?(code)
        end
      end

      # Sort through the results from Isobib, fetching them three at a time,
      # and return the first result that matches the code,
      # matches the year (if provided), and which # has a title (amendments do
      # not).
      # Only expects the first page of results to be populated.
      # Does not match corrigenda etc (e.g. ISO 3166-1:2006/Cor 1:2007)
      # If no match, returns any years which caused mismatch, for error
      # reporting
      def results_filter(result, year) # rubocop:disable Metrics/AbcSize,Metrics/CyclomaticComplexity,Metrics/MethodLength
        missed_years = []
        result.each_slice(3) do |s| # ISO website only allows 3 connections
          fetch_pages(s, 3).each do |r|
            return { ret: r } if !year

            r.date.select { |d| d.type == "published" }.each do |d|
              return { ret: r } if year.to_i == d.on(:year)

              missed_years << d.on(:year)
            end
          end
        end
        { years: missed_years }
      end

      # @param hits [RelatonBib::HitCollection<RelatonBib::Hit>]
      # @param threads [Integer]
      # @return [Array<RelatonBib::GbBibliographicItem>]
      def fetch_pages(hits, threads)
        workers = RelatonBib::WorkersPool.new threads
        workers.worker { |w| { i: w[:i], hit: w[:hit].fetch } }
        hits.each_with_index { |hit, i| workers << { i: i, hit: hit } }
        workers.end
        workers.result.sort_by { |x| x[:i] }.map { |x| x[:hit] }
      end
    end
  end
end
