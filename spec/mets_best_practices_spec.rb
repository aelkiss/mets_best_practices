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

# adds a new dmdSec after the last metsHdr or dmdSec
def add_dmdsec(doc,dmdid)
  doc.xpath('(//xmlns:metsHdr | //xmlns:dmdSec)[last()]').first.add_next_sibling(create_node(doc,'dmdSec',{ID: dmdid}))
end

def first_div(doc)
  doc.xpath('//xmlns:div').first
end

# adds a new metadata section (techMD, rightsMD, digiprovMD, sourceMD) in the first amdSec
# if there is no amdSec, adds it after the last metsHdr or dmdSec
def add_mdsec(doc,mdname,admid)
  amdsec = doc.xpath('//xmlns:amdSec').first
  if !amdsec
    amdsec = create_node(doc,'amdSec')
    doc.xpath('(//xmlns:metsHdr | //xmlns:dmdSec)[last()]').first.add_next_sibling(amdsec)
  end

  amdsec.add_child(create_node(doc,mdname,{ID: admid}))
end

# adds a new fileGrp to the first fileSec
# if there is no fileSec, adds it after the last metsHdr, dmdSec or amdSec
def add_filegrp(doc)
  filesec = doc.xpath('//xmlns:fileSec').first
  if !filesec
    filesec = create_node(doc,'fileSec')
    doc.xpath('(//xmlns:metsHdr | //xmlns:dmdSec | //xmlns:amdSec)[last()]').first.add_next_sibling(filesec)
  end

  filesec.add_child(create_node(doc,'fileGrp'))
end

describe 'mets_best_practices.sch' do

  subject { run_schematron(xml_doc) }
  let(:first_error) { subject.first[:message] }

  shared_examples_for "no errors" do
    # TODO: should be valid w/ XSD
    it { is_expected.to be_empty }
  end

  shared_examples_for "one error" do |pattern|
    # TODO: should be valid w/ XSD
    it "has one message" do
      expect(subject.length).to eq(1)
    end

    it "has an error matching #{pattern}" do
      expect(subject.first[:message]).to match(pattern)
    end
  end

  context 'with a minimal mets' do
    let(:xml_doc) { minimal_mets }
    it_behaves_like "no errors"
  end

  describe 'dmdsec-id-checks' do

    context 'with one unreferenced dmdsec' do
      let(:xml_doc) do
        minimal_mets.tap do |doc|
          add_dmdsec(doc,'dmd1')
        end
      end

      it_behaves_like 'one error', /The dmdSec with ID "dmd1" is never referenced by a DMDID attribute/
    end

    context 'with one properly referenced dmdsec' do
      let(:xml_doc) do
        minimal_mets.tap do |doc|
          add_dmdsec(doc,'dmd1')
          doc.xpath('//xmlns:div').first['DMDID'] = 'dmd1'
        end
      end

      it_behaves_like "no errors"
    end

    context 'with two dmdsecs, one referenced, one not' do
      let(:xml_doc) do
        minimal_mets.tap do |doc|
          add_dmdsec(doc,'dmd1')
          add_dmdsec(doc,'dmd2')
          doc.xpath('//xmlns:div').first['DMDID'] = 'dmd1'
        end
      end

      it_behaves_like 'one error', /The dmdSec with ID "dmd2" is never referenced by a DMDID attribute/
    end

    context 'with a dmdid referencing a non-dmdsec' do
      let(:xml_doc) do
        minimal_mets.tap do |doc|
          add_mdsec(doc,'techMD','tmd1')
          doc.xpath('//xmlns:div').first['DMDID'] = 'tmd1'
        end
      end

      it_behaves_like 'one error', /The DMDID "tmd1" should reference a dmdSec, not a techMD/
    end

  end


  describe 'file-begin-end-checks' do
  
    context 'with a file with BEGIN, END, BETYPE attributes that does not have a parent file' do
      let(:xml_doc) do
        minimal_mets.tap do |doc|
          filegrp = add_filegrp(doc)
          filegrp.add_child(create_node(doc,'file',{BEGIN: '1', END: '1000', BETYPE: 'BYTE'}))
        end
      end

      it_behaves_like 'one error', /A file with BEGIN, END or BETYPE attributes should have a parent file/
    end

    context 'with a nested file with BEGIN and END but not BETYPE' do
      let(:xml_doc) do
        minimal_mets.tap do |doc|
          filegrp = add_filegrp(doc)
          file = filegrp.add_child(create_node(doc,'file'))
          file.add_child(create_node(doc,'file',{BEGIN: '1', END: '1000'}))
        end
      end

      it_behaves_like 'one error', /A file with BEGIN, END or BETYPE attributes should have BEGIN and BETYPE./
    end 

    context 'with a nested file with BEGIN and BETYPE but not END' do
      let(:xml_doc) do
        minimal_mets.tap do |doc|
          filegrp = add_filegrp(doc)
          file = filegrp.add_child(create_node(doc,'file'))
          file.add_child(create_node(doc,'file',{BEGIN: '1', BETYPE: '1000'}))
        end
      end

      it_behaves_like 'one error', /When no END attribute is specified, the end of the parent file is assumed also to be the end point of the current file./
    end 

  end


  describe 'fptr-fileid-checks' do
  
    context 'with a fptr element with FILEID and no children' do
      let(:xml_doc) do
        minimal_mets.tap do |doc|
          add_filegrp(doc).add_child(create_node(doc,'file',{ID: 'file1'}))
          first_div(doc).add_child(create_node(doc,'fptr',{FILEID: 'file1'}))
        end
      end

      it_behaves_like 'no errors'
    end

    context 'with a fptr element with FILEID and children' do
      let(:xml_doc) do
        minimal_mets.tap do |doc|
          add_filegrp(doc).add_child(create_node(doc,'file',{ID: 'file1'}))
          first_div(doc).add_child(create_node(doc,'fptr',{FILEID: 'file1'}))
                   .add_child(create_node(doc,'area',{FILEID: 'file1'}))
        end
      end

      it_behaves_like 'one error', /A fptr element should only have a FILEID attribute value if it does not have a child area, par or seq element./
    end

    context 'with a fptr element with children but no FILEID' do
      let(:xml_doc) do
        minimal_mets.tap do |doc|
          add_filegrp(doc).add_child(create_node(doc,'file',{ID: 'file1'}))
          first_div(doc).add_child(create_node(doc,'fptr'))
                   .add_child(create_node(doc,'area',{FILEID: 'file1'}))
        end
      end

      it_behaves_like 'no errors'
    end

  end

end
