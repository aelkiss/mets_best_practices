require 'spec_helper'

describe "file-id-checks" do
  
  let(:xml_doc) { minimal_mets_template(innards) }

  context "with one unreferenced file" do
    let(:innards) do <<EOT
    <fileSec>
      <fileGrp>
        <file ID="FILE1" />
      </fileGrp>
    </fileSec>

    <structMap>
      <div />
    </structMap>
EOT
    end

    it_behaves_like "one schematron error", /WARNING: The file with ID "FILE1" is never referenced by a FILEID attribute/
  end

  context "with one properly referenced file" do
    let(:innards) do <<EOT
    <fileSec>
      <fileGrp>
        <file ID="FILE1" />
      </fileGrp>
    </fileSec>

    <structMap>
      <div>
        <fptr FILEID="FILE1" />
      </div>
    </structMap>
EOT
    end

    it_behaves_like "no errors"
  end

  context "with two files, one referenced, one not" do
    let(:innards) do <<EOT
    <fileSec>
      <fileGrp>
        <file ID="FILE1" />
        <file ID="FILE2" />
      </fileGrp>
    </fileSec>

    <structMap>
      <div>
        <fptr FILEID="FILE1" />
      </div>
    </structMap>
EOT
    end

    it_behaves_like "one schematron error", /WARNING: The file with ID "FILE2" is never referenced by a FILEID attribute/
  end

  context "with a fileid referencing a non-file" do
    let(:innards) do <<EOT
   <amdSec>
     <techMD ID='TMD1' />
   </amdSec>

   <structMap>
     <div ADMID="TMD1">
       <fptr FILEID="TMD1" />
     </div>
   </structMap>
EOT
    end

    it_behaves_like "one schematron error", /ERROR: The FILEID "TMD1" should reference a file, not a techMD/
  end

end
