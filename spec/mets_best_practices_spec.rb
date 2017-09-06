require "nokogiri"
require "schematron-nokogiri"
require "pry"

def minimal_mets
  Nokogiri::XML File.open File.join(File.dirname(__FILE__), 'minimal_mets.xml')
end

def run_schematron(xml_doc)
  stron_doc = Nokogiri::XML File.open File.join(File.dirname(__FILE__), '../mets_best_practices.sch')
  stron = SchematronNokogiri::Schema.new stron_doc
  stron.validate xml_doc
end

def create_node(doc,name,attrs={})
  Nokogiri::XML::Node.new(name,doc).tap do |node|
    attrs.each { |k,v| node[k.to_s] = v }
  end
end

def add_dmdsec(doc,dmdid)
  doc.xpath('//METS:metsHdr | //METS:dmdSec').last.add_next_sibling(create_node(doc,'dmdSec',{ID: dmdid}))
end

def add_mdsec(doc,mdname,admid)
  amdsec = doc.xpath('//METS:amdSec').first
  if !amdsec
    amdsec = create_node(doc,'amdSec')
    doc.xpath('//METS:metsHdr | //METS:dmdSec | //METS:amdSec').last.add_next_sibling(amdsec)
  end

  amdsec.add_child(create_node(doc,mdname,{ID: admid}))
end

# load the schematron xml
# 
#
# # make a schematron object
# 
#
# # load the xml document you wish to validate
# xml_doc = XML::Document.file "/path/to/my_xml_document.xml"
#
# # validate it
# 

describe 'mets_best_practices.sch' do

  subject { run_schematron(xml_doc) }
  let(:first_error) { subject.first[:message] }

  shared_examples_for "no errors" do
    it { is_expected.to be_empty }
  end

  shared_examples_for "one error" do |pattern|
    it "has one message" do
      expect(subject.length).to be(1)
    end

    it "has an error matching #{pattern}" do
      expect(subject.first[:message]).to match(pattern)
    end
  end

  context 'with a minimal mets' do
    let(:xml_doc) { minimal_mets }
    it_behaves_like "no errors"
  end

  # pattern: dmdsec-id-checks

  context 'with one unreferenced dmdsec' do
    let(:xml_doc) do
      minimal_mets.tap do |doc|
        add_dmdsec(doc,'dmd1')
      end
    end

    it_behaves_like 'one error', /The dmdSec @ID "dmd1" is never referenced/
  end

  context 'with one properly referenced dmdsec' do
    let(:xml_doc) do
      minimal_mets.tap do |doc|
        add_dmdsec(doc,'dmd1')
        doc.xpath('//METS:div').first['DMDID'] = 'dmd1'
      end
    end

    it_behaves_like "no errors"
  end

  context 'with two dmdsecs, one referenced, one not' do
    let(:xml_doc) do
      minimal_mets.tap do |doc|
        add_dmdsec(doc,'dmd1')
        add_dmdsec(doc,'dmd2')
        doc.xpath('//METS:div').first['DMDID'] = 'dmd1'
      end
    end

    it_behaves_like 'one error', /The dmdSec @ID "dmd2" is never referenced/
  end

  context 'with a dmdid referencing a non-dmdsec' do
    let(:xml_doc) do
      minimal_mets.tap do |doc|
        add_mdsec(doc,'techMD','tmd1')
        doc.xpath('//METS:div').first['DMDID'] = 'tmd1'
      end
    end

    it_behaves_like 'one error', /The @DMDID "tmd1" should reference a dmdSec, not a techMD/
  end

end
