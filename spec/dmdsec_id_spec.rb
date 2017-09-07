require 'spec_helper'

describe 'dmdsec-id-checks' do

	context 'with one unreferenced dmdsec' do
		let(:xml_doc) do
			minimal_mets.tap do |doc|
				add_dmdsec(doc,'dmd1')
			end
		end

		it_behaves_like 'one schematron error', /The dmdSec with ID "dmd1" is never referenced by a DMDID attribute/
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

		it_behaves_like 'one schematron error', /The dmdSec with ID "dmd2" is never referenced by a DMDID attribute/
	end

	context 'with a dmdid referencing a non-dmdsec' do
		let(:xml_doc) do
			minimal_mets.tap do |doc|
				add_mdsec(doc,'techMD','tmd1')
				doc.xpath('//xmlns:div').first['DMDID'] = 'tmd1'
			end
		end

		it_behaves_like 'one schematron error', /The DMDID "tmd1" should reference a dmdSec, not a techMD/
	end

end
