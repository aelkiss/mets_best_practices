require 'spec_helper'

describe 'file-begin-end-checks' do
  let(:xml_doc) do
    minimal_mets_template(innards)
  end

  context 'with a file with BEGIN, END, BETYPE attributes that does not have a parent file' do
    let(:innards) do <<EOT
      <fileSec>
        <fileGrp>
          <file BEGIN="1" END="1000" BETYPE="BYTE" ID="file1" />
        </fileGrp>
      </fileSec>

      <structMap>
        <div>
          <fptr FILEID="file1" />
        </div>
      </structMap>
EOT
    end

    it_behaves_like 'one schematron error', /ERROR: A file with BEGIN, END or BETYPE attributes should have a parent file/
  end

  context 'with a nested file with BEGIN and END but not BETYPE' do
    let(:innards) do <<EOT
      <fileSec>
        <fileGrp>
          <file ID="file1" >
            <file ID="file2" BEGIN="1" END="1000" />
          </file>
        </fileGrp>
      </fileSec>

      <structMap>
        <div>
          <fptr FILEID="file1" />
          <fptr FILEID="file2" />
        </div>
      </structMap>
EOT
    end

    it_behaves_like 'one schematron error', /ERROR: A file with BEGIN, END or BETYPE attributes should have BEGIN and BETYPE./
  end 

  context 'with a nested file with BEGIN and BETYPE but not END' do
    let(:innards) do <<EOT
      <fileSec>
        <fileGrp>
          <file ID="file1" >
            <file ID="file2" BEGIN="1" BETYPE="BYTE" />
          </file>
        </fileGrp>
      </fileSec>

      <structMap>
        <div>
          <fptr FILEID="file1" />
          <fptr FILEID="file2" />
        </div>
      </structMap>
EOT
    end

    it_behaves_like 'one schematron error', /INFO: When no END attribute is specified, the end of the parent file is assumed also to be the end point of the current file./
  end 

end
