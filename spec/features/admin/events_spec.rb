require 'rails_helper'

feature 'Admin events', :omniauth do
  scenario 'unlogged user redirect to root' do
    visit '/admin/events'

    expect(page.current_path).to eq root_path
  end

  scenario 'logged user (not admin) redirect to root' do
    sign_in(create(:user))

    visit '/admin/events'

    expect(page.current_path).to eq root_path
  end

  context 'logged user' do
    before { sign_in(create(:user_admin)) }

    scenario 'list events on index page' do
      happened     = create(:event_happened)
      not_happened = create(:event_not_happened)

      visit '/admin/events'

      %i(name local address occurred_at).each do |field|
        expect(page).to have_content happened.send(field)
        expect(page).to have_content not_happened.send(field)
      end

      # TODO: Check button to create a new event
      # expect(page).to have_content 'New event'
    end

    scenario 'add new event' do
      visit '/admin/events/new'

      fill_in 'event_name',        with: 'Event #1'
      fill_in 'event_local',       with: 'Local #1'
      fill_in 'event_address',     with: 'Address #1'
      fill_in 'event_occurred_at', with: Time.zone.now
      fill_in 'event_summary',     with: 'Oh bla dih, oh bla dah'
      fill_in 'event_description', with: 'Oh bla dih, oh bla dah'

      find('input[type="submit"]').click

      expect(page).to have_content 'Event #1'
      expect(page).to have_content 'Local #1'
    end

    scenario 'add fails incomplete event' do
      visit '/admin/events/new'

      find('input[type="submit"]').click

      expect(page).to have_content(error_text_for(:blank))
    end

    scenario 'edit event' do
      event = create(:event_happened)

      visit "/admin/events/#{event.slug}/edit"

      fill_in 'event_name',        with: 'Event #1.1'
      fill_in 'event_local',       with: 'Local #1.1'
      fill_in 'event_address',     with: 'Address #1.1'

      find('input[type="submit"]').click

      expect(page).to have_content 'Event #1.1'
      expect(page).to have_content 'Local #1.1'
      expect(page).to have_content 'Address #1.1'
    end

    scenario 'edit fails incomplete event' do
      event = create(:event_happened)

      visit "/admin/events/#{event.slug}/edit"
      fill_in 'event_name', with: ''
      find('input[type="submit"]').click

      expect(page).to have_content(error_text_for(:blank))
    end

    scenario 'destroy event' do
      event = create(:event_happened)

      visit '/admin/events'

      first('.btn-delete').click

      expect(page).to_not have_content event.name
    end
  end
end
