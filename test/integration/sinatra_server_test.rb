require 'test_helper'

class SinatraServerTest < ActionDispatch::IntegrationTest

  test "local call returns locally-served data" do
    visit JsonServer.base+'/json/sinatra'
    assert page.has_content?("Sinatra Test!")
  end

end