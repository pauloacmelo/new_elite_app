require 'spec_helper'

describe 'CardTypes' do
  before(:each) { log_admin_in }

  it 'shows all card types' do
    (1..10).each { |i| create :card_type, name: "CardType#{i}" }

    visit card_types_url

    (1..10).each { |i| page.should have_content "CardType#{i}" }
  end

  it 'creates an card type' do
    visit card_types_url
    click_link 'New Card Type'
    fill_in 'Name', with: 'AnwerCardType'
    fill_in 'Parameters', with: '1 2 3 4 5'
    fill_in 'Student number length', with: '7'
    attach_file 'Card', "#{Rails.root}/spec/support/card_b.tif"
    click_button 'Create'

    page.should have_content 'Card type was successfully created.'
    CardType.count.must.equal 1
  end

  it 'updates an card type' do
    create :card_type

    visit card_types_url
    click_link 'Edit'
    fill_in 'Name', with: 'NewCardType'
    click_button 'Update'

    page.should have_content 'Card type was successfully updated.'
    CardType.count.must.equal 1
  end
end