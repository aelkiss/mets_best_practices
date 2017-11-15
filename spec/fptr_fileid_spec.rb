require 'spec_helper'

describe 'fptr-fileid-checks' do

  context 'with a fptr element' do
    let(:xml_doc) do
      minimal_mets_template(innards)
    end

    context 'with FILEID and no children' do
      let(:innards) do <<EOT
        <fileSec>
          <fileGrp>
            <file ID="file1" />
          </fileGrp>
        </fileSec>

        <structMap>
          <div>
            <fptr FILEID="file1" />
          </div>
        </structMap>

EOT
      end

      it_behaves_like 'no errors'
    end

    context 'with FILEID and children' do
      let(:innards) do <<EOT
        <fileSec>
          <fileGrp>
            <file ID="file1" />
          </fileGrp>
        </fileSec>

        <structMap>
          <div>
            <fptr FILEID="file1">
              <area FILEID="file1" />
            </fptr>
          </div>
        </structMap>

EOT
      end

      it_behaves_like 'one schematron error', /ERROR: A fptr element should only have a FILEID attribute value if it does not have a child area, par or seq element./
    end

    context 'with children but no FILEID' do
      let(:innards) do <<EOT
        <fileSec>
          <fileGrp>
            <file ID="file1" />
          </fileGrp>
        </fileSec>

        <structMap>
          <div>
            <fptr>
              <area FILEID="file1" />
            </fptr>
          </div>
        </structMap>

EOT
      end

      it_behaves_like 'no errors'
    end

    context 'with no child and no FILEID' do
      let(:innards) do <<EOT
        <structMap>
          <div>
            <fptr />
          </div>
        </structMap>

EOT
      end

      it_behaves_like 'one schematron error', /ERROR: A fptr element should have a FILEID attribute if it does not have child area, par, or seq elements./
    end

  end

end
