# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Rails::MailersController, type: :controller do
  render_views

  let(:notify) { double(:notify) }
  let(:preview) { double(Notifications::Client::TemplatePreview) }

  before do
    allow(Notifications::Client).to receive(:new).with('some-api-key') { notify }
    allow(notify).to receive(:generate_template_preview).with(
      'template-id',
      personalisation: {
        body: "bar\r\n\\\r\n* This\r\n* Is\r\n* A\r\n* List",
        subject: 'Hello there!'
      }
    ) { preview }
    allow(preview).to receive(:html) { '<p>Some HTML</p>' }
  end

  context 'with part specified' do
    it 'gets the HTML preview' do
      get :preview, params: { path: 'welcome/my_mail', part: 'text/html' }

      expect(response.body).to eq('<p>Some HTML</p>')
    end

    it 'returns a HTML content type' do
      get :preview, params: { path: 'welcome/my_mail', part: 'text/html' }

      expect(response.content_type).to eq('text/html')
    end
  end

  context 'without part specified' do
    it 'returns an iframe' do
      get :preview, params: { path: 'welcome/my_mail' }

      regex = %r{<iframe seamless name="messageBody" src="\?part=text%2Fhtml"><\/iframe>}
      expect(response.body).to match(regex)
    end
  end
end
