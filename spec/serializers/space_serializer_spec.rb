require 'spec_helper'

describe SpaceSerializer do
  let :user do
    valid! fixture :user
  end

  let :space do
    valid! user.create_default_space
  end

  subject { described_class.new space }

  it 'should render' do
    output = subject.as_json.with_indifferent_access

    output[:space][:id].should == "#{space.id}"
    output[:space][:title].should == "#{space.title}"
    output[:space][:pretty_title].should == "#{space.pretty_title}"
  end

  it 'should escape :title, :pretty_title, :brief' do
    space.title = 'M&Ms'
    space.brief = 'M&Ms gone wild.'

    output = subject.as_json.with_indifferent_access
    output[:space][:title].should == "M&amp;Ms"
    output[:space][:pretty_title].should == "m-ms"
    output[:space][:brief].should == "M&amp;Ms gone wild."
  end
end