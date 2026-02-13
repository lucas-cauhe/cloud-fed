# frozen_string_literal: true

require 'spec_helper'
require 'puppet/type/rados'

RSpec.describe 'the rados type' do
  it 'loads' do
    expect(Puppet::Type.type(:rados)).not_to be_nil
  end
end
