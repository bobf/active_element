# frozen_string_literal: true

RSpec.describe 'navbar' do
  let(:permissions) { %w[can_list_dummy_examples] }
  let(:navbar_items) do
    [{ label: 'Users',
       path: '/admin/users',
       controller_name: 'users' },
     { label: 'Permissions',
       path: '/admin/permissions',
       controller_name: 'permissions' }]
  end

  before do
    sign_in(create(:user, permissions: permissions))
    allow(ActiveElement).to receive(:navbar_items).and_return(navbar_items)
    allow(ActiveElement).to receive(:application_title).and_return('Example Application')
  end

  it 'displays navbar title' do
    get '/examples'
    expect(document.div('.navbar').a('.navbar-brand')).to match_text 'Example Application'
  end

  it 'displays navbar items' do
    get '/examples'
    expect(document.div('.navbar').li('.nav-item')).to match_text 'Permissions'
  end
end
