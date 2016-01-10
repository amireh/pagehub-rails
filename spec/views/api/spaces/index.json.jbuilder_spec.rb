require 'rails_helper'

describe 'api/spaces/index.json.jbuilder' do
  let(:user) { a_user }
  let(:space) { a_space(user) }

  it 'should render' do
    output = render_jbuilder_template({ spaces: [ space ] })

    expect(output[:spaces][0][:id]).to eq "#{space.id}"
    expect(output[:spaces][0][:title]).to eq "#{space.title}"
    expect(output[:spaces][0][:pretty_title]).to eq "#{space.pretty_title}"
  end

  it 'should escape :title, :pretty_title, :brief' do
    space.title = 'M&Ms'
    space.brief = 'M&Ms gone wild.'

    output = render_jbuilder_template(spaces: [ space ])

    expect(output[:spaces][0][:title]).to eq "M&amp;Ms"
    expect(output[:spaces][0][:pretty_title]).to eq "m-ms"
    expect(output[:spaces][0][:brief]).to eq "M&amp;Ms gone wild."
  end
end