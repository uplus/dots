
describe 'bcho' do
  context 'digit arg' do
    # it{ expect(`bcho 1234`).to eq "\xd2\04"}
  end

  context 'hex arg' do
    it{ expect(`bcho 0x1234`).to eq "\x34\x12"}
    it{ expect(`bcho 0x12340`).to eq "\x40\x23\01"}
    it{ expect(`bcho 0x123400`).to eq "\x00\x34\x12"}
    it{ expect(`bcho 0x01234`).to eq "\x34\x12\x00"}
  end

  context 'string arg' do
    it{ expect(`bcho 0x`).to eq "\x30\x78"}
    it{ expect(`bcho abc`).to eq "abc"}
    it{ expect(`bcho string`).to eq "string"}
    it{ expect(`bcho ls\\0`).to eq "ls0"}
  end

  context 'multi arg' do
    it{ expect(`bcho ls 0`).to eq "ls\0"}
  end
end
