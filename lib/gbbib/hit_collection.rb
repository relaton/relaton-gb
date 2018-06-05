# frozen_string_literal: true

module Gbbib
  # Page of hit collection
  class HitCollection < Array
    # @return [TrueClass, FalseClass]
    attr_reader :fetched

    # @return [Isobib::HitPages]
    attr_reader :hit_pages

    # @return [Gbbib::GbScrapper, Gbbib::SecScrapper, Gbbib::TScrapper]
    attr_reader :scrapper

    # @param hits [Array<Hash>]
    # @param hit_pages [Integer]
    # @param scrapper [Gbbib::GbScrapper, Gbbib::SecScrapper, Gbbib::TScrapper]
    def initialize(hits = nil, hit_pages = nil)
      concat hits
      @fetched   = false
      @hit_pages = hit_pages
    end

    # @return [Isobib::HitCollection]
    # def fetch
    #   workers = WorkersPool.new 4
    #   workers.worker(&:fetch)
    #   each do |hit|
    #     workers << hit
    #   end
    #   workers.end
    #   workers.result
    #   @fetched = true
    #   self
    # end

    # def to_s
    #   inspect
    # end
    #
    # def inspect
    # "<#{self.class}:#{format('%#.14x', object_id << 1)} @fetched=#{@fetched}>"
    # end
  end
end
