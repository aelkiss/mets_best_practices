require 'spec_helper'
require 'pry'

describe "mdsec-id-checks" do
  
  mdsec_adder = lambda do |doc,element,id| 
    add_mdsec(doc,element,id)
  end

  ["techMD","rightsMD","sourceMD","digiprovMD"].each do |mdsec|
    it_behaves_like "all ids are referenced", 'ADMID',mdsec,'div',mdsec_adder
  end

  mdsec_doc_builder = lambda do |doc,id|
    add_mdsec(doc,"dmdSec",id)
    doc.xpath("//xmlns:div").first["ADMID"] = id
    doc.xpath("//xmlns:div").first["DMDID"] = id
  end

  it_behaves_like "idref type checking", "ADMID", ['techMD','rightsMD','sourceMD','digiprovMD'], 'dmdSec', mdsec_doc_builder

end
