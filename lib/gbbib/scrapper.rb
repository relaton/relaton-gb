# encoding: UTF-8

require 'yaml'

module Gbbib
  # Common scrapping methods.
  module Scrapper
    @prefixes = nil

    def scrapped_data(doc, src:)
      {
        committee: get_committee(doc),
        docid:     get_docid(doc),
        titles:    get_titles(doc),
        type:      get_type(doc),
        docstatus: get_status(doc),
        gbtype:    get_gbtype(doc),
        ccs:       get_ccs(doc),
        ics:       get_ics(doc),
        source:    [{ type: 'src', content: src }],
        dates:     get_dates(doc)
      }
    end

    def get_docid(doc, xpt = '//dt[text()="标准号"]/following-sibling::dd[1]')
      item_ref = doc.xpath(xpt)
                    .text.match(/(?<=\s)(\d+)-?((?<=-)\d+|)/)
      { project_number: item_ref[1], part_number: item_ref[2] }
    end

    def get_titles(doc)
      titles = [{ title_intro: doc.css('div.page-header h4').text,
                  title_main: '', language: 'zh', script: 'Hans' }]
      title_intro = doc.css('div.page-header h5').text
      unless title_intro.empty?
        titles << { title_intro: title_intro, title_main: '', language: 'en',
                    script: 'Latn' }
      end
      titles
    end

    def get_type(doc)
      get_scope(doc) + '-standard'
    end

    def get_status(doc, xpt = '.s-status.label')
      status = case doc.at(xpt).text.gsub(/\s/, '')
               when '即将实施' then 'published'
               when '现行' then 'activated'
               when '废止' then 'obsoleted'
               end
      { status: status, stage: '', substage: '' }
    end

    private

    def get_gbtype(doc)
      ref = get_ref(doc)
      { scope: get_scope(doc), prefix: get_prefix(ref)['prefix'],
        mandate: get_mandate(ref) }
    end

    def get_ref(doc)
      doc.xpath('//dt[text()="标准号"]/following-sibling::dd[1]').text
    end

    def get_ccs(doc)
      [doc.xpath('//dt[text()="中国标准分类号"]/following-sibling::dd[1]').text]
    end

    def get_ics(doc)
      ics = doc.xpath('//dt[(.="国际标准分类号")]/following-sibling::dd[1]/span')
      field, group, subgroup = ics.text.split '.'
      [{ field: field, group: group.ljust(3, '0'), subgroup: subgroup }]
    end

    def get_scope(doc)
      scope = doc.at('.s-status.label-info').text
      if scope == '国家标准'
        'national'
      elsif scope =~ /^行业标准/
        'industry'
      end
    end

    def get_prefix(ref)
      pref = ref.match(/^[^\s]+/).to_s.split('/').first
      prefix pref
    end

    def prefix(pref)
      file_path = File.join(__dir__, 'yaml/prefixes.yaml')
      @prefixes ||= YAML.load_file(file_path)
      @prefixes[pref]
    end

    def get_mandate(ref)
      case ref.match(%r{(?<=\/)[^\s]+}).to_s
      when 'T' then 'recommended'
      when 'Z' then 'guideline'
      else 'mandatory'
      end
    end

    def get_dates(doc)
      date = doc.xpath('//dt[.="发布日期"]/following-sibling::dd[1]').text
      [{ type: 'published', from: date }]
    end
  end
end
