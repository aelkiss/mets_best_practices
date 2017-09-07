require 'spec_helper'

describe 'fptr-fileid-checks' do

	context 'with a fptr element' do

		context 'with FILEID and no children' do
			let(:xml_doc) do
				minimal_mets.tap do |doc|
					add_filegrp(doc).add_child(create_node(doc,'file',{ID: 'file1'}))
					first_div(doc).add_child(create_node(doc,'fptr',{FILEID: 'file1'}))
				end
			end

			it_behaves_like 'no errors'
		end

		context 'with FILEID and children' do
			let(:xml_doc) do
				minimal_mets.tap do |doc|
					add_filegrp(doc).add_child(create_node(doc,'file',{ID: 'file1'}))
					first_div(doc).add_child(create_node(doc,'fptr',{FILEID: 'file1'}))
						.add_child(create_node(doc,'area',{FILEID: 'file1'}))
				end
			end

			it_behaves_like 'one schematron error', /A fptr element should only have a FILEID attribute value if it does not have a child area, par or seq element./
		end

		context 'with children but no FILEID' do
			let(:xml_doc) do
				minimal_mets.tap do |doc|
					add_filegrp(doc).add_child(create_node(doc,'file',{ID: 'file1'}))
					first_div(doc).add_child(create_node(doc,'fptr'))
						.add_child(create_node(doc,'area',{FILEID: 'file1'}))
				end
			end

			it_behaves_like 'no errors'
		end

		context 'with no child and no FILEID' do
			let(:xml_doc) do
				minimal_mets.tap do |doc|
					first_div(doc).add_child(create_node(doc,'fptr'))
				end
			end

			it_behaves_like 'one schematron error', /A fptr element should have a FILEID attribute if it does not have child area, par, or seq elements./
		end

	end

end
