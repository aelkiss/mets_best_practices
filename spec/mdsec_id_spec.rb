require 'spec_helper'
require 'pry'

describe "mdsec-id-checks" do
  let(:xml_doc) { minimal_mets_template(innards) }

  mdsec_adder = lambda do |doc,element,id| 
    add_mdsec(doc,element,id)
  end

  ["techMD","rightsMD","sourceMD","digiprovMD"].each do |mdsec|
    context "with one unreferenced dmdSec" do
      let(:innards) do <<EOT
        <amdSec>
          <#{mdsec} ID="AMD1" />
        </amdSec>

        <structMap>
          <div />
        </structMap>
EOT
      end

      it_behaves_like "one schematron error", /WARNING: The #{mdsec} with ID "AMD1" is never referenced by a ADMID attribute/
    end

    context "with one properly referenced #{mdsec}" do
      let(:innards) do <<EOT
        <amdSec>
          <#{mdsec} ID="AMD1" />
        </amdSec>

        <structMap>
          <div ADMID='AMD1' />
        </structMap>
EOT
      end

      it_behaves_like "no errors"
    end

    context "with two #{mdsec}s, one referenced, one not" do
      let(:innards) do <<EOT
        <amdSec>
          <#{mdsec} ID="AMD1" />
          <#{mdsec} ID="AMD2" />
        </amdSec>

        <structMap>
          <div ADMID="AMD1"  />
        </structMap>
EOT
      end

      it_behaves_like "one schematron error", /WARNING: The #{mdsec} with ID "AMD2" is never referenced by a ADMID attribute/
    end
  end

  context "with an admid referencing a dmdSec" do
    let(:innards) do <<EOT
      <dmdSec ID='DMD1' />

      <structMap>
        <div DMDID='DMD1' ADMID='DMD1' />
      </structMap>
EOT
    end

    it_behaves_like "one schematron error", /ERROR: The ADMID "DMD1" should reference a .*, not a dmdSec/
  end

end
