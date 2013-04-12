require 'test_helper'

class CrunchbaseImportTest < ActionDispatch::IntegrationTest

  def setup
    WebMock.stub_request(:any, /api.crunchbase.com/).to_rack(JsonServer)
  end

  test "navigate to page and import a file" do

    visit root_path

    assert page.has_link?("Edit an existing Investments.js file")
    assert page.has_link?("Create a new Investments.js file")

    click_link "Create a new Investments.js file"

    assert page.has_link?("importing your data")

    click_link "importing your data"

    assert page.has_content?("Import information from Crunchbase")

    fill_in('investment[url]', :with => 'http://www.crunchbase.com/financial-organization/neu-venture-capital')

    click_button "Import my Crunchbase data"

    assert page.has_content?("Edit your Investments.js file")

    assert page.has_xpath?("//input[@value='Union Square Ventures']")
    assert page.has_xpath?("//input[@value='http://www.usv.com/']")
    assert page.has_xpath?("//input[@value='Wesabe']")
    assert page.has_xpath?("//input[@value='http://www.yieldbot.com']")

  end

  test "try to import gibberish" do

    visit crunchbase_investors_path

    fill_in('investment[url]', :with => JsonServer.base+'/json/malformed')

    click_button "Import my Crunchbase data"

    assert page.has_content?("We're sorry, but that wasn't a valid Crunchbase URL.")
    assert page.has_no_content?("Edit your Investments.js file")

  end

  test "import a crunchbase file without investment information" do

    visit crunchbase_investors_path

    fill_in('investment[url]', :with => 'http://www.crunchbase.com/company/yieldbot')

    click_button "Import my Crunchbase data"

    assert page.has_content?("Create a new Investments.js file")
    assert page.has_no_content?("Edit your Investments.js file")
    assert page.has_content?("We're sorry - we couldn't retrieve any investment information from that Crunchbase page.")

  end

end