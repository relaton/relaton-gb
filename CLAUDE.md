# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

relaton-gb is a Ruby gem for searching and fetching Chinese GB (Guobiao) standards bibliographic data. It's part of the Relaton family of gems and scrapes standards from Chinese government websites.

## Common Commands

```bash
# Install dependencies
bin/setup

# Run all tests
bundle exec rake spec

# Run a single test file
bundle exec rspec spec/relaton_gb_spec.rb

# Run a specific test by line number
bundle exec rspec spec/relaton_gb_spec.rb:31

# Interactive console for experimenting
bin/console

# Lint with RuboCop (uses Ribose OSS style guide)
bundle exec rubocop

# Install gem locally
bundle exec rake install
```

## Architecture

### Entry Point
`RelatonGb::GbBibliography` is the main API class:
- `search(text)` - Returns `HitCollection` of search results
- `get(code, year, opts)` - Fetches a specific standard by identifier

### Scrapers (lib/relaton_gb/)
Each scraper handles a different standard source:
- `GbScrapper` - National standards (GB/GJ/GS prefix) from openstd.samr.gov.cn
- `TScrapper` - Social organization standards (T/XX prefix) from www.ttbz.org.cn
- `Scrapper` - Common scraping methods shared via `extend`

The scrapers use Mechanize for HTTP requests and Nokogiri for HTML parsing.

### Domain Models
- `GbBibliographicItem` - Main bibliographic item class, extends `RelatonIsoBib::IsoBibliographicItem`
- `Hit` / `HitCollection` - Search result wrappers with lazy fetching via `hit.fetch`
- `GbStandardType` - Standard classification (scope, mandate, prefix)
- `GbTechnicalCommittee` - Technical committee information

### Data Flow
1. `GbBibliography.search` routes to appropriate scraper based on standard prefix
2. Scraper returns `HitCollection` with basic metadata
3. Calling `hit.fetch` scrapes the full document page and returns `GbBibliographicItem`
4. `GbBibliographicItem` can serialize to XML, hash, or AsciiBib

## Testing

Tests use RSpec with VCR to record/replay HTTP interactions:
- VCR cassettes stored in `spec/vcr_cassettes/`
- Cassettes auto-expire after 7 days (`re_record_interval`)
- XML output validated against RelaxNG schemas in `grammars/`

To re-record a VCR cassette, delete the corresponding YAML file and run the test.

## Important Notes

- GB standard searches **require the year** in the identifier (e.g., `GB/T 20223-2006`, not `GB/T 20223`)
- Standard prefixes define the type: GB/GJ/GS = national, T/XX = social organization
- The `/T` suffix in prefix indicates "recommended" (推荐), `/Z` indicates "guidelines"
