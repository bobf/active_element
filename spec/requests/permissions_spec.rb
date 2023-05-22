# frozen_string_literal: true

RSpec.describe '/example_permissions' do
  before { sign_in(create(:user, permissions: permissions)) }

  describe '/example_permissions' do
    before { public_send(action, path) }

    shared_examples 'an authorized request' do |verification_string, user_permissions|
      let(:permissions) { %w[can_access_admin] + user_permissions }

      it 'provides access' do
        expect(document).to match_text "#{verification_string} Access Granted"
      end

      it 'returns 200 OK' do
        expect(response).to have_http_status :ok
      end
    end

    shared_examples 'a rejected request' do |user_permissions|
      let(:permissions) { user_permissions }

      it 'does not provide access' do
        expect(document).not_to match_text 'Access Granted'
      end

      it 'returns 403 Forbidden' do
        expect(response).to have_http_status :forbidden
      end
    end

    context 'with user with appropriate default #index permission' do
      let(:path) { '/example_permissions' }
      let(:action) { :get }

      it_behaves_like 'an authorized request', 'List', %w[can_list_dummy_example_permissions]
      it_behaves_like 'a rejected request', %w[can_do_something_else]
    end

    context 'with user with appropriate default #show permission' do
      let(:path) { '/example_permissions/1' }
      let(:action) { :get }

      it_behaves_like 'an authorized request', 'View', %w[can_view_dummy_example_permissions]
      it_behaves_like 'a rejected request', %w[can_do_something_else]
    end

    context 'with user with appropriate default #edit permission' do
      let(:path) { '/example_permissions/1/edit' }
      let(:action) { :get }

      it_behaves_like 'an authorized request', 'Edit', %w[can_edit_dummy_example_permissions]
      it_behaves_like 'a rejected request', %w[can_do_something_else]
    end

    context 'with user with appropriate default #update permission' do
      let(:path) { '/example_permissions/1' }
      let(:action) { :patch }

      it_behaves_like 'an authorized request', 'Update', %w[can_edit_dummy_example_permissions]
      it_behaves_like 'a rejected request', %w[can_do_something_else]
    end

    context 'with user with appropriate default #new permission' do
      let(:path) { '/example_permissions/new' }
      let(:action) { :get }

      it_behaves_like 'an authorized request', 'New', %w[can_create_dummy_example_permissions]
      it_behaves_like 'a rejected request', %w[can_do_something_else]
    end

    context 'with user with appropriate default #create permission' do
      let(:path) { '/example_permissions' }
      let(:action) { :post }

      it_behaves_like 'an authorized request', 'Create', %w[can_create_dummy_example_permissions]
      it_behaves_like 'a rejected request', %w[can_do_something_else]
    end

    context 'with user with appropriate custom permissions for a custom route' do
      let(:path) { '/example_permissions/1/custom' }
      let(:action) { :get }

      it_behaves_like 'an authorized request', 'Custom', %w[can_access_example]
      it_behaves_like 'a rejected request', %w[can_do_something_else]
    end

    context 'with user with no permissions for a custom route' do
      let(:path) { '/example_permissions/1/custom' }
      let(:action) { :get }

      it_behaves_like 'a rejected request', []
    end

    context 'with user with no permissions for unprotected route' do
      let(:permissions) { [] }
      let(:path) { '/example_permissions/1/unprotected' }
      let(:action) { :get }

      it 'renders an error' do
        expect(response).to have_http_status :internal_server_error
      end
    end

    context 'with user with inappropriate permissions for unprotected route' do
      let(:permissions) { %w[can_access_other_thing] }
      let(:path) { '/example_permissions/1/unprotected' }
      let(:action) { :get }

      it 'renders an error' do
        expect(response).to have_http_status :internal_server_error
      end
    end
  end

  describe '/admin/examples' do
    context 'with user with appropriate permissions' do
      let(:permissions) { %w[can_list_dummy_admin_examples] }

      it 'requires namespaced permission' do
        get '/admin/examples'
        expect(document).to match_text 'Admin Examples List Access Granted'
      end
    end

    context 'with user with inappropriate permissions' do
      let(:permissions) { %w[can_access_other_thing] }

      it 'requires namespaced permission' do
        get '/admin/examples'
        expect(document).not_to match_text 'Admin Examples List Access Granted'
      end
    end

    context 'with user with no permissions' do
      let(:permissions) { [] }

      it 'requires namespaced permission' do
        get '/admin/examples'
        expect(document).not_to match_text 'Admin Examples List Access Granted'
      end
    end
  end

  context 'with incorrect permissions, other resources permitted, but not root path' do
    let(:permissions) { %w[can_list_dummy_admin_examples] }

    it 'redirects to permitted resource' do
      get '/admin/examples/1'
      expect(response).to have_http_status :forbidden
    end
  end

  context 'with correct permissions, other resources permitted, but not root path' do
    let(:permissions) { %w[can_list_dummy_admin_permitted_alternatives] }

    it 'redirects to permitted resource' do
      get '/admin/examples/1'
      expect(response).to have_http_status :forbidden
    end

    it 'suggests alternative available routes' do
      get '/admin/examples/1'
      expect(document.div('.alternative-links').a).to match_text 'Permitted Alternatives'
    end
  end

  context 'with incorrect permissions, other resources permitted, for root path' do
    let(:permissions) { %w[can_list_dummy_admin_permitted_alternatives] }

    it 'redirects to permitted resource' do
      get '/'
      expect(response).to redirect_to '/admin/permitted_alternatives'
    end
  end
end
