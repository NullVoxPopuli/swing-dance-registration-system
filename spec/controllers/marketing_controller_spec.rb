require 'spec_helper'

describe MarketingController do

  describe '#redirect_url_for' do
    let(:controller) { MarketingController.new }

    APPLICATION_CONFIG['domain'].each do |env_name, domain|

      before(:each) do
        allow(controller).to receive(:current_domain){ domain }
      end

      context env_name do


        it 'redirects' do
          requested_url = "https://subdomain1.#{domain}"
          result = controller.send(:redirect_url_for, requested_url, domain)
          expect(result).to eq "https://#{domain}/subdomain1/"
        end

        it 'respects the protocol' do
          requested_url = "http://subdomain2.#{domain}"
          result = controller.send(:redirect_url_for, requested_url, domain)
          expect(result).to eq "http://#{domain}/subdomain2/"
        end

        it 'removes the path' do
          requested_url = "http://subdomain3.#{domain}/this/does/not/matter"
          result = controller.send(:redirect_url_for, requested_url, domain)
          expect(result).to eq "http://#{domain}/subdomain3/"
        end
      end
    end
  end
end
