# frozen_string_literal: true

require "relaton/gb/processor"

describe Relaton::Gb::Processor do
  subject(:processor) { described_class.new }

  describe "#initialize" do
    it "sets short to :relaton_gb" do
      expect(processor.short).to eq :relaton_gb
    end

    it "sets prefix to CN" do
      expect(processor.prefix).to eq "CN"
    end

    it "sets defaultprefix to match GB standards" do
      expect(processor.defaultprefix).to eq(/^(GB|GB\/T|GB\/Z) /)
    end

    it "sets idtype to Chinese Standard" do
      expect(processor.idtype).to eq "Chinese Standard"
    end

    it "matches GB standard codes" do
      expect("GB 123").to match(processor.defaultprefix)
      expect("GB/T 456").to match(processor.defaultprefix)
      expect("GB/Z 789").to match(processor.defaultprefix)
    end

    it "does not match non-GB standard codes" do
      expect("ISO 123").not_to match(processor.defaultprefix)
      expect("JB/T 456").not_to match(processor.defaultprefix)
    end
  end

  describe "#get" do
    it "fetches bibliography item" do
      expect(Relaton::Gb::Bibliography).to receive(:get)
        .with("GB/T 20223", "2006", {})
        .and_return(double("ItemData"))

      result = processor.get("GB/T 20223", "2006", {})
      expect(result).not_to be_nil
    end

    it "returns nil when item not found" do
      expect(Relaton::Gb::Bibliography).to receive(:get)
        .with("GB/T 99999", nil, {})
        .and_return(nil)

      result = processor.get("GB/T 99999", nil, {})
      expect(result).to be_nil
    end
  end

  describe "#from_xml" do
    let(:xml) { File.read("spec/fixtures/bibitem.xml", encoding: "UTF-8") }

    it "creates ItemData from XML" do
      item = processor.from_xml(xml)
      expect(item).to be_a(Relaton::Gb::ItemData)
    end
  end

  describe "#from_yaml" do
    let(:yaml) { File.read("spec/fixtures/item.yaml", encoding: "UTF-8") }

    it "creates ItemData from YAML string" do
      item = processor.from_yaml(yaml)
      expect(item).to be_a(Relaton::Gb::ItemData)
    end
  end

  describe "#grammar_hash" do
    it "returns grammar hash string" do
      expect(processor.grammar_hash).to be_a(String)
      expect(processor.grammar_hash).not_to be_empty
    end

    it "memoizes the result" do
      first_call = processor.grammar_hash
      second_call = processor.grammar_hash
      expect(first_call).to eq second_call
    end
  end
end
