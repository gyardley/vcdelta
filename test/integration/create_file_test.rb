require 'test_helper'

# really could use some serious DRYing out

class CreateFileTest < ActionDispatch::IntegrationTest

  test "create a one-entry investments.json file" do

    visit root_path

    assert page.has_link?("Load an existing Investments.json file")
    assert page.has_link?("Create a new Investments.json file")

    click_link "Create a new Investments.json file"

    assert page.has_button?("I'm done - create my Investments.json file!")

    fill_in('investor[companies_attributes][0][name]', :with => 'Dummy Corp')
    fill_in('investor[companies_attributes][0][url]', :with => 'http://dummy.com/')
    fill_in('investor[companies_attributes][0][rounds_attributes][0][name]', :with => 'Seed')
    fill_in('investor[companies_attributes][0][events_attributes][0][name]', :with => 'Acquihire')
    select('January', :from => 'investor[companies_attributes][0][rounds_attributes][0][date(2i)]')
    select('2010', :from => 'investor[companies_attributes][0][rounds_attributes][0][date(1i)]')

    click_button "I'm done - create my Investments.json file!"

    assert page.has_content?("Your Investments.json file is ready!")
    assert page.has_content?("Dummy Corp")
    assert page.has_content?("http://dummy.com/")
    assert page.has_content?("Seed")
    assert page.has_content?("Acquihire")
    assert page.has_content?("01/2010")

    assert JSON::parse(page.find(".well").text)

  end

  test "create a one-entry investments.json file with two rounds, two events" do

    visit new_investor_path

    click_link "Add another round"
    click_link "Add another event"

    fill_in('investor[companies_attributes][0][name]', :with => 'Dummy Corp')
    fill_in('investor[companies_attributes][0][url]', :with => 'http://dummy.com/')
    fill_in('investor[companies_attributes][0][rounds_attributes][0][name]', :with => 'Seed')
    fill_in('investor[companies_attributes][0][events_attributes][0][name]', :with => 'Acquihire')
    select('January', :from => 'investor[companies_attributes][0][rounds_attributes][0][date(2i)]')
    select('2010', :from => 'investor[companies_attributes][0][rounds_attributes][0][date(1i)]')

    # the way nested_forms inserts random numbers in ID names is seriously irritating
    page.find(:xpath, "(//div[contains(concat(' ', @class, ' '), ' investor_companies_rounds_name ')])[last()]/div/input").set("Series A")
    page.find(:xpath, "(//div[contains(concat(' ', @class, ' '), ' investor_companies_events_name ')])[last()]/div/input").set("IPO")

    click_button "I'm done - create my Investments.json file!"

    assert page.has_content?("Dummy Corp")
    assert page.has_content?("http://dummy.com/")
    assert page.has_content?("Seed")
    assert page.has_content?("Acquihire")
    assert page.has_content?("01/2010")
    assert page.has_content?("Series A")
    assert page.has_content?("IPO")

    assert JSON::parse(page.find(".well").text)

  end

  test "create a one-entry investments.json file with one blank round & one blank event" do

    visit new_investor_path

    click_link "Add another round"
    click_link "Add another event"

    fill_in('investor[companies_attributes][0][name]', :with => 'Dummy Corp')
    fill_in('investor[companies_attributes][0][url]', :with => 'http://dummy.com/')
    # setting the first round to whitespace, will just leave second event blank
    fill_in('investor[companies_attributes][0][rounds_attributes][0][name]', :with => '  ')
    fill_in('investor[companies_attributes][0][events_attributes][0][name]', :with => 'Acquihire')
    select('January', :from => 'investor[companies_attributes][0][rounds_attributes][0][date(2i)]')
    select('2010', :from => 'investor[companies_attributes][0][rounds_attributes][0][date(1i)]')

    page.find(:xpath, "(//div[contains(concat(' ', @class, ' '), ' investor_companies_rounds_name ')])[last()]/div/input").set("Series A")

    click_button "I'm done - create my Investments.json file!"

    results = JSON::parse(page.find(".well").text)

    assert results
    assert_equal results[0]["rounds"].length, 1
    assert_equal results[0]["events"].length, 1

  end

  test "create a two-entry investments.json file" do

    visit new_investor_path

    click_link "Add another investment"

    fill_in('investor[companies_attributes][0][name]', :with => 'Dummy Corp')
    fill_in('investor[companies_attributes][0][url]', :with => 'http://dummy.com/')
    fill_in('investor[companies_attributes][0][rounds_attributes][0][name]', :with => 'Seed')
    fill_in('investor[companies_attributes][0][events_attributes][0][name]', :with => 'Acquihire')
    select('January', :from => 'investor[companies_attributes][0][rounds_attributes][0][date(2i)]')
    select('2010', :from => 'investor[companies_attributes][0][rounds_attributes][0][date(1i)]')

    # we'll fill in the name but leave the rest of the fields blank in order to test that too
    page.find(:xpath, "(//div[contains(concat(' ', @class, ' '), ' investor_companies_name ')])[last()]/div/input").set("Wonder Corp")

    click_button "I'm done - create my Investments.json file!"

    assert page.has_content?("Dummy Corp")
    assert page.has_content?("Wonder Corp")

    results = JSON::parse(page.find(".well").text)

    assert results
    assert_equal results.length, 2
    assert !results[1].has_key?("rounds")
    assert !results[1].has_key?("events")

  end

  test "create a two-entry investments.json file with blank second investment name" do

    visit new_investor_path

    click_link "Add another investment"

    fill_in('investor[companies_attributes][0][name]', :with => 'Dummy Corp')
    fill_in('investor[companies_attributes][0][url]', :with => 'http://dummy.com/')
    fill_in('investor[companies_attributes][0][rounds_attributes][0][name]', :with => 'Seed')
    fill_in('investor[companies_attributes][0][events_attributes][0][name]', :with => 'Acquihire')
    select('January', :from => 'investor[companies_attributes][0][rounds_attributes][0][date(2i)]')
    select('2010', :from => 'investor[companies_attributes][0][rounds_attributes][0][date(1i)]')

    # click on the round and event links for the new investment
    page.find(:xpath, "(//a[text()='Add another round'])[last()]").click
    page.find(:xpath, "(//a[text()='Add another event'])[last()]").click

    page.find(:xpath, "(//div[contains(concat(' ', @class, ' '), ' investor_companies_rounds_name ')])[last()]/div/input").set("Series A")
    page.find(:xpath, "(//div[contains(concat(' ', @class, ' '), ' investor_companies_events_name ')])[last()]/div/input").set("IPO")

    click_button "I'm done - create my Investments.json file!"

    assert page.has_content?("Dummy Corp")
    assert page.has_no_content?("Series A")
    assert page.has_no_content?("IPO")

    results = JSON::parse(page.find(".well").text)

    assert results
    assert_equal results.length, 1

  end

  test "submit a blank form, get an error" do

    visit new_investor_path

    click_button "I'm done - create my Investments.json file!"

    assert page.has_button?("I'm done - create my Investments.json file!")
    assert page.has_no_content?("Your Investments.json file is ready!")
    assert page.has_content?("Sorry, but you'll have to give us a little information for this to work out.")

  end

end