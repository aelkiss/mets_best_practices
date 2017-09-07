RSpec.shared_context "mets_best_practices" do
	subject { run_schematron(xml_doc) }
	let(:first_error) { subject.first[:message] }
	let(:mets_schema) { Nokogiri::XML::Schema(File.open File.join(File.dirname(__FILE__), 'mets.xsd')) }
	let(:schematron) do
		stron_doc = Nokogiri::XML File.open File.join(File.dirname(__FILE__), '../mets_best_practices.sch')
		stron = SchematronNokogiri::Schema.new stron_doc
	end

end
