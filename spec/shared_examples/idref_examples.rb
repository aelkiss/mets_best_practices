# ensures that that all elements with name element that have IDs are referenced
# by an IDREF in an attribute with name attr on an element with name
# ref_element

RSpec.shared_examples_for "all ids are referenced" do |attr,element,ref_element,elt_adder|

    id = "#{element.downcase}1"
    unreferenced_id = "#{element.downcase}2"

    context "with one unreferenced #{element}" do
      let(:xml_doc) do
        minimal_mets.tap do |doc|
          # add_mdsec(doc,mdsec,mdsec_id)
          elt_adder.call(doc,element,id)
        end
      end

      it_behaves_like "one schematron error", /WARNING: The #{element} with ID "#{id}" is never referenced by a #{attr} attribute/
    end

    context "with one properly referenced #{element}" do
      let(:xml_doc) do
        minimal_mets.tap do |doc|
          elt_adder.call(doc,element,id)
          doc.xpath("//xmlns:#{ref_element}").first[attr] = id
        end
      end

      it_behaves_like "no errors"
    end

    context "with two #{element}s, one referenced, one not" do
      let(:xml_doc) do
        minimal_mets.tap do |doc|
          elt_adder.call(doc,element,id)
          elt_adder.call(doc,element,unreferenced_id)
#          add_mdsec(doc,mdsec,mdsec_id)
#          add_mdsec(doc,mdsec,another_mdsec_id)
          doc.xpath("//xmlns:#{ref_element}").first[attr] = id
        end
      end

      it_behaves_like "one schematron error", /WARNING: The #{element} with ID "#{unreferenced_id}" is never referenced by a #{attr} attribute/
    end

end

# ensures that IDREFs in attr refer to elements with one of the names in element
RSpec.shared_examples_for "idref type checking" do |attr,elements,wrong_element,doc_builder|
  id = "testid"

  context "with a dmdid referencing a non-dmdsec" do
    let(:xml_doc) do
      minimal_mets.tap do |doc|
        doc_builder.call(doc,id)
      end
    end

    it_behaves_like "one schematron error", /ERROR: The #{attr} "#{id}" should reference a #{or_join(elements)}, not a #{wrong_element}/
  end

end
