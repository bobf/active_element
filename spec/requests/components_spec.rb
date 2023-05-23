# frozen_string_literal: true

RSpec.describe '/components' do
  let(:permissions) { %w[can_list_dummy_components] }

  before do
    create(:example)
    sign_in(create(:user, permissions: permissions))
  end

  describe 'GET /components' do
    before { get '/components' }

    it 'renders inferred navbar title' do
      expect(document.div('.application-menu.navbar').a('.navbar-brand')).to match_text 'Dummy'
    end

    it 'renders inferred navbar items' do
      expect(document.div('.application-menu.navbar').ul('.navbar-nav').li('.nav-item')).to match_text 'Examples'
    end

    it 'renders a page title' do
      expect(document.h2).to match_text 'Page Title'
    end

    it 'renders a page subtitle' do
      expect(document.h3).to match_text 'Page Subtitle'
    end

    it 'renders a section title' do
      expect(document.h4).to match_text 'Section Title'
    end

    it 'renders a page description' do
      expect(document).to match_text('Page Description').once
    end

    it 'renders a button' do
      expect(document.a(class: 'btn', href: '/path/to/example/resource')).to match_text 'Example Button'
    end

    it 'renders an item table with headings' do
      expect(document.table('.table.example').th.all.map(&:text)).to eql %w[Name Email Password Secret]
    end

    it 'renders an item table with decorated fields' do
      expect(document.table('.table.example').td('.example-email').a[:href]).to eql 'mailto:user@example.com'
    end

    it 'renders an item table with a decorated field that uses the default value in a given context' do
      expect(document.table('.table.examples').td('.examples-email').span('.default-value'))
        .to match_text 'user@example.com'
    end

    it 'renders an item table with values' do
      expect(document.table('.table.example').td.all.map(&:text).compact_blank)
        .to eql ['My Name', 'user@example.com']
    end

    it 'renders a secret field in an item table' do
      expect(document.table('.table.example').td('.example-secret').span[:'data-secret'])
        .to eql 'user-secret'
    end

    it 'renders a collection table with headings' do
      expect(document.table('.table.examples').th.all.map(&:text).compact_blank)
        .to eql %w[Name Email Password Secret]
    end

    it 'renders a collection table with values and action buttons' do
      expect(document.table('.table.examples').td.all.map(&:text).compact_blank)
        .to eql ['My Name', 'user@example.com', 'View', 'Edit', 'Delete']
    end

    it 'renders a "Create New..." button' do
      expect(document.a(class: 'btn new-button')).to match_text 'Create New Example'
    end

    it 'renders a secret field in a collection table' do
      expect(document.table('.table.examples').td('.examples-secret').span[:'data-secret'])
        .to eql 'user-secret'
    end

    it 'renders a form with input fields' do
      expect(document.form('.example').input(type: 'text').all.pluck(:value))
        .to eql ['My Name', 'user@example.com']
    end

    it 'renders tabs with tab headings' do
      expect(document.nav('.my-tabs').div('.nav-tabs').a('#nav-example-tab')).to match_text 'Example'
    end

    it 'renders tabs with tab content' do
      expect(document.div('.tab-content').div('.example')).to match_text 'My content'
    end
  end
end
