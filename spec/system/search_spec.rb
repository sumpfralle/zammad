# Copyright (C) 2012-2021 Zammad Foundation, http://zammad-foundation.org/

require 'rails_helper'

RSpec.describe 'Search', type: :system, searchindex: true do
  before do
    configure_elasticsearch(required: true, rebuild: true)
  end

  it 'shows default widgets' do
    fill_in id: 'global-search', with: '"Welcome"'

    click_on 'Show Search Details'

    within '#navigation .tasks a[data-key=Search]' do
      expect(page).to have_text '"Welcome"'
    end
  end

  context 'inactive user and organizations' do
    before do
      create(:organization, name: 'Example Inc.', active: true)
      create(:organization, name: 'Example Inactive Inc.', active: false)
      create(:customer, firstname: 'Firstname', lastname: 'Active', active: true)
      create(:customer, firstname: 'Firstname', lastname: 'Inactive', active: false)

      configure_elasticsearch(rebuild: true)
    end

    it 'check that inactive organizations are marked correctly' do
      fill_in id: 'global-search', with: '"Example"'

      expect(page).to have_css('.nav-tab--search.organization', minimum: 2)
      expect(page).to have_css('.nav-tab--search.organization.is-inactive', count: 1)
    end

    it 'check that inactive users are marked correctly' do
      fill_in id: 'global-search', with: '"Firstname"'

      expect(page).to have_css('.nav-tab--search.user', minimum: 2)
      expect(page).to have_css('.nav-tab--search.user.is-inactive', count: 1)
    end

    it 'check that inactive users are also marked in the popover for the quick search result' do
      fill_in id: 'global-search', with: '"Firstname"'

      popover_on_hover(find('.nav-tab--search.user.is-inactive'))

      expect(page).to have_css('.popover-title .is-inactive', count: 1)
    end
  end
end
