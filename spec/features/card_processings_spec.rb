require 'spec_helper'
require 'sidekiq'
require 'sidekiq/testing'

describe 'CardProcessings' do
  before(:each) { log_admin_in }

  it 'creates a card processing' do
    create :exam
    create :card_type, name: 'Type B'
    create :campus, name: 'Campus'

    visit card_processings_path
    click_link 'New Card Processing'
    fill_in 'Name', with: 'Name'
    fill_in 'card_processing_exam_date', with: '2013-12-12'
    select 'Type B', from: 'Card type' 
    select 'Campus', from: 'Campus'
    attach_file 'File', File.join(Rails.root, 'spec/support/card_a.tif') 
    click_button 'Create'

    page.should have_content 'Card processing was successfully created.'
    CardProcessing.count.should == 1

    CardProcessorWorker.drain
    CardProcessing.first.status.should == CardProcessing::PROCESSED_STATUS
  end
end