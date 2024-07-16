# frozen_string_literal: true

require 'sinatra'
require 'json'
require 'csv'
require_relative 'scraper'

class YCombinatorScraperApp < Sinatra::Base
  configure do
    set :bind, '0.0.0.0' # Allow access from external IP addresses
    set :port, 4567 # Set the desired port for Sinatra to listen on
  end

  get '/' do
    'Y Combinator Scraper API'
  end

  post '/scrape' do
    content_type :json
    request.body.rewind
    begin
      data = JSON.parse(request.body.read)
    rescue JSON::ParserError
      return { status: 'error', message: 'Invalid JSON' }.to_json
    end

    n = data['n']
    filters = data['filters'] || {}

    scraper = YCombinatorScraper.new(n, filters)
    companies = scraper.scrape

    return { status: 'error', message: 'No companies found' }.to_json if companies.empty?

    csv_string = CSV.generate(headers: true) do |csv|
      csv << %w[name location description batch website founders linkedin_urls]
      companies.each do |company|
        csv << [
          company[:name],
          company[:location],
          company[:description],
          company[:batch],
          company[:website],
          company[:founders].join(', '),
          company[:linkedin_urls].join(', ')
        ]
      end
    end

    { status: 'success', csv: csv_string }.to_json
  end

  run! if app_file == $PROGRAM_NAME
end
