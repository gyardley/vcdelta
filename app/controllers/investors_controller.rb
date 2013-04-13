require "net/http"
require "uri"

class InvestorsController < ApplicationController

  skip_before_filter :require_login

  def new

    @investor = Investor.new
    @company = @investor.companies.new
    @company.rounds.new
    @company.events.new
    @partial = 'investors/new'

  end # new

  def create

    @partial = 'investors/new'

    investor_params = params.require(:investor).permit(
      :investor,
      :url,
      {:companies_attributes =>
        [:name, :url, :_destroy,
          {:rounds_attributes => [:name, :date, :_destroy]},
          {:events_attributes => [:name, :date, :_destroy]}
        ]
      }
    )

    @investor = Investor.new(investor_params)

    if @investor.valid?

      @investor.version = '1.0.0'
      @investor.updated = Time.now

      @companies = @investor.companies.reject { |company| company.name.blank? }
      @companies.each do |company|
        company.rounds = company.rounds.reject { |round| round.name.blank? }
        company.events = company.events.reject { |event| event.name.blank? }
      end

      if @companies.length == 0
        flash.now[:error] = "You'll have to give us a little information about your investments for this to work." # change?
        render 'new'
      end

    else # validation errors
      flash.now[:error] = "Whoops. Please correct the highlighted errors first."
      render 'new'
    end

  end # create

  def load
  end

  def parse

    if params[:investment][:url].blank?
      render 'load'
    else

      json_object = json_file_pull(params[:investment][:url])

      if json_object.nil?
        flash.now[:error] = "That didn't work - either the URL was wrong or the content wasn't valid."
        render 'load'
      else
        @investor = create_investor(json_object)
        unless @investor.companies.any?
          flash[:error] = "We're sorry - we couldn't retrieve any data from that file."
        end
        @partial = 'investors/edit'
        render 'new'
      end

    end

  end # parse


  def crunchbase
  end

  def import

    if params[:investment][:url].blank?
      flash.now[:error] = "You'll have to enter a Crunchbase URL."
      render 'crunchbase'
    end

    uri = URI::parse(params[:investment][:url])

    if (params[:investment][:url] =~ URI::regexp('http')).nil?

      flash.now[:error] = "We're sorry, but that wasn't a valid URL."
      render 'crunchbase'

    elsif !uri.host or !uri.host.include? "crunchbase.com"

      flash.now[:error] = "We're sorry, but that wasn't a valid Crunchbase URL."
      render 'crunchbase'

    else

      @investor = crunchbase_api(uri.path)

      if @investor.companies.any?
        @partial = 'investors/import'
        render 'new'
      else
        @partial = 'investors/new'
        flash.now[:error] = "We're sorry - we couldn't retrieve any investment information from that Crunchbase page."
        render 'new'
      end

    end

  end

  protected

  # ghetto error handling - if it's nil something went wrong and I don't much care what
  def json_file_pull(url)
    begin
      JSON.parse HTTParty.get(url).response.body
    rescue
      nil
    end
  end # json_file_pull

  # takes the json object and makes an investor out of it
  def create_investor(json_object)

    if json_object.include?("name") && json_object["name"] == "investments.js" && json_object.include?("version") && json_object["version"] == "1.0.0"
      format_1_0_0(json_object)
    else
      format_0(json_object)
    end

  end # create_investor

  # for dealing with Jerry's original file format without API version
  def format_0(json_object)

    investor = Investor.new

    companies = json_object.reject { |item| !item.include?("company") }

    companies.map { |data|
      company = investor.companies.new(:name => data["company"], :url => data["url"])
      data["rounds"].map { |round| company.rounds.new(:name => round["Series"], :date => Date.strptime(round["date"], "%m/%Y")) } if data["rounds"]
      data["events"].map { |event| company.events.new(:name => event["event"], :date => Date.strptime(event["date"], "%m/%Y")) } if data["events"]
    }

    investor

  end

  # for the 1.0.0 specification.
  def format_1_0_0(json_object)

    investor = Investor.new
    investor.investor = json_object["investor"]
    investor.url = json_object["url"] if json_object["url"]

    companies = json_object["investments"].reject { |item| !item.include?("company") }

    companies.map { |data|
      company = investor.companies.new(:name => data["company"], :url => data["url"])
      data["rounds"].map { |round| company.rounds.new(:name => round["series"], :date => Date.strptime(round["date"], "%m/%Y")) } if data["rounds"]
      data["events"].map { |event| company.events.new(:name => event["event"], :date => Date.strptime(event["date"], "%m/%Y")) } if data["events"]
    }

    investor

  end

  def crunchbase_api(path)

    api_base = 'http://api.crunchbase.com/v/1/'
    api_key = ENV['CRUNCHBASE_API_KEY']

    crunchbase_url = api_base+path+".js?api_key="+api_key

    investor = Investor.new

    begin

      response = JSON.parse HTTParty.get(crunchbase_url).response.body

      if response["name"]
        investor.investor = response["name"].strip
      elsif response["first_name"] and response["last_name"]
        investor.investor = response["first_name"].strip+' '+response["last_name"].strip
      end

      investor.url = response["homepage_url"]

      if response["investments"]

        companies = Hash.new { |h,k| h[k] = [] }

        response["investments"].map do |data|

          investment = data["funding_round"]

          companies[investment["company"]["name"]] << {
            name:       investment["round_code"].strip.capitalize,
            date:       Date.strptime("#{investment["funded_month"]}/#{investment["funded_year"]}", "%m/%Y"),
            permalink:  investment["company"]["permalink"].strip
          }

        end

        companies.each do |data|

          # need to fetch the damn company URLs from the company pages because they're not in the investor API call
          crunchbase_company_url = "#{api_base}company/"+data[1][0][:permalink]+".js?api_key=#{api_key}"

          begin
            company_response = JSON.parse HTTParty.get(crunchbase_company_url).response.body
            company_url = company_response["homepage_url"].strip
          rescue JSON::ParserError # timeouts, just skip fetching the url
          end

          company = investor.companies.new(:name => data[0], :url => company_url)
          # company = investor.companies.new(:name => data[0])

          data[1].map { |round| company.rounds.new(:name => round[:name], :date => round[:date]) }

        end

      end
    rescue
    end

    investor

  end

end