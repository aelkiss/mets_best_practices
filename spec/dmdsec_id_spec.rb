require 'spec_helper'

describe 'dmdsec-id-checks' do
  let(:xml_doc) { minimal_mets_template(innards) }

  context "with one unreferenced dmdSec" do
    let(:innards) do <<EOT
<dmdSec ID="DMD1" />
<structMap>
<div>
</structMap>
EOT
    end

    it_behaves_like "one schematron error", /WARNING: The dmdSec with ID "DMD1" is never referenced by a DMDID attribute/
  end

  context "with one properly referenced dmdSec" do
    let(:innards) do <<EOT
    <dmdSec ID="DMD1" />

    <structMap>
      <div DMDID='DMD1' />
    </structMap>
EOT
    end

    it_behaves_like "no errors"
  end

  context "with two dmdSecs, one referenced, one not" do
    let(:innards) do <<EOT
    <dmdSec ID="DMD1" />
    <dmdSec ID="DMD2" />

    <structMap>
      <div DMDID="DMD1"  />
    </structMap>
EOT
    end

    it_behaves_like "one schematron error", /WARNING: The dmdSec with ID "DMD2" is never referenced by a DMDID attribute/
  end

  context "with a dmdid referencing a non-dmdsec" do
    let(:innards) do <<EOT
   <amdSec>
     <techMD ID='TMD1' />
   </amdSec>
   <structMap>
     <div DMDID='TMD1' ADMID='TMD1' />
   </structMap>
EOT
    end

    it_behaves_like "one schematron error", /ERROR: The DMDID "TMD1" should reference a dmdSec, not a techMD/
  end

end
