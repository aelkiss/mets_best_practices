require 'spec_helper'

describe 'dmdsec-id-checks' do
  dmdsec_adder = lambda do |doc,_,id| 
    add_dmdsec(doc,id)
  end

  it_behaves_like "all ids are referenced", 'DMDID','dmdSec','div',dmdsec_adder

  dmdsec_doc_builder = lambda do |doc,id|
    add_mdsec(doc,'techMD',id)
    doc.xpath('//xmlns:div').first['DMDID'] = id
    doc.xpath('//xmlns:div').first['ADMID'] = id
  end

  it_behaves_like "idref type checking", "DMDID", ['dmdSec'], 'techMD', dmdsec_doc_builder

end
