RSpec.shared_examples_for "no errors" do
  include_context "mets_best_practices"

	it "validates against the schematron" do
		expect(schematron.validate(xml_doc)).to be_empty
	end

	xit "validates against the xsd" do
		expect(mets_schema.validate(xml_doc)).to be_empty
	end
end

RSpec.shared_examples_for "one schematron error" do |pattern|
  include_context "mets_best_practices"

	it "has one schematron error when validated against the schematron" do
		expect(schematron.validate(xml_doc).length).to eq(1)
	end
	it "has an error from schematron validation matching #{pattern}" do
		expect(schematron.validate(xml_doc).first[:message]).to match(pattern)
	end

	xit "validates against the xsd" do
		expect(mets_schema.validate(xml_doc)).to be_empty
	end
end
