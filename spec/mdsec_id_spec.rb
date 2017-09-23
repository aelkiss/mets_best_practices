require 'spec_helper'

describe "mdsec-id-checks" do

  ["techMD","rightsMD","sourceMD","digiprovMD"].each do |mdsec|
    mdsec_id = "#{mdsec.downcase}1"
    another_mdsec_id = "#{mdsec.downcase}2"

    context "with one unreferenced #{mdsec}" do
      let(:xml_doc) do
        minimal_mets.tap do |doc|
          add_mdsec(doc,mdsec,mdsec_id)
        end
      end

      it_behaves_like "one schematron error", /WARNING: The #{mdsec} with ID "#{mdsec_id}" is never referenced by a ADMID attribute/
    end

    context "with one properly referenced #{mdsec}" do
      let(:xml_doc) do
        minimal_mets.tap do |doc|
          add_mdsec(doc,mdsec,mdsec_id)
          doc.xpath("//xmlns:div").first["ADMID"] = mdsec_id
        end
      end

      it_behaves_like "no errors"
    end

    context "with two #{mdsec}s, one referenced, one not" do
      let(:xml_doc) do
        minimal_mets.tap do |doc|
          add_mdsec(doc,mdsec,mdsec_id)
          add_mdsec(doc,mdsec,another_mdsec_id)
          doc.xpath("//xmlns:div").first["ADMID"] = mdsec_id
        end
      end

      it_behaves_like "one schematron error", /WARNING: The #{mdsec} with ID "#{another_mdsec_id}" is never referenced by a ADMID attribute/
    end

  end

  context "with a dmdid referencing a non-dmdsec" do
    let(:xml_doc) do
      minimal_mets.tap do |doc|
        add_mdsec(doc,"dmdSec","dmd1")
        doc.xpath("//xmlns:div").first["ADMID"] = "dmd1"
        doc.xpath("//xmlns:div").first["DMDID"] = "dmd1"
      end
    end

    it_behaves_like "one schematron error", /ERROR: The ADMID "dmd1" should reference a techMD, rightsMD, sourceMD, or digiprovMD, not a dmdSec/
  end

end
