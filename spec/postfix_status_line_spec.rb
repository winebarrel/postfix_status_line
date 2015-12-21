require 'spec_helper'

describe PostfixStatusLine do
  it 'has a version number' do
    expect(PostfixStatusLine::VERSION).not_to be nil
  end

  it 'hav a core moduke' do
    expect(PostfixStatusLine::Core).not_to be nil
  end
end
