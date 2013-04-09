require 'test_helper'

class IntegrationTest < ActionDispatch::IntegrationTest

  test "create a one-entry investments.json file" do

    visit root_path

    assert page.has_link?("Load an existing file")
    assert page.has_link?("Create a new file")

    click_link "Create a new file"

    assert page.has_content?("Create a new Investments.json file")

    fill_in('investor[companies_attributes][0][name]', :with => 'Dummy Corp')
    fill_in('investor[companies_attributes][0][rounds_attributes][0][name]', :with => 'Seed')
    fill_in('investor[companies_attributes][0][events_attributes][0][name]', :with => 'Acquihire')

  end

end