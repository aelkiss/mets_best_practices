require 'spec_helper'

describe 'file-begin-end-checks' do

	context 'with a file with BEGIN, END, BETYPE attributes that does not have a parent file' do
		let(:xml_doc) do
			minimal_mets.tap do |doc|
				filegrp = add_filegrp(doc)
				filegrp.add_child(create_node(doc,'file',{BEGIN: '1', END: '1000', BETYPE: 'BYTE', ID:'file1'}))
			end
		end

		it_behaves_like 'one schematron error', /A file with BEGIN, END or BETYPE attributes should have a parent file/
	end

	context 'with a nested file with BEGIN and END but not BETYPE' do
		let(:xml_doc) do
			minimal_mets.tap do |doc|
				filegrp = add_filegrp(doc)
				file = filegrp.add_child(create_node(doc,'file',{ID: 'file1'}))
				file.add_child(create_node(doc,'file',{BEGIN: '1', END: '1000',ID: 'file2'}))
			end
		end

		it_behaves_like 'one schematron error', /A file with BEGIN, END or BETYPE attributes should have BEGIN and BETYPE./
	end 

	context 'with a nested file with BEGIN and BETYPE but not END' do
		let(:xml_doc) do
			minimal_mets.tap do |doc|
				filegrp = add_filegrp(doc)
				file = filegrp.add_child(create_node(doc,'file',{ID: 'file1'}))
				file.add_child(create_node(doc,'file',{BEGIN: '1', BETYPE: 'BYTE',ID: 'file2'}))
			end
		end

		it_behaves_like 'one schematron error', /When no END attribute is specified, the end of the parent file is assumed also to be the end point of the current file./
	end 

end
