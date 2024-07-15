# frozen_string_literal: true

require 'selenium-webdriver'
require 'nokogiri'
require 'csv'
require 'httparty'

class YCombinatorScraper
  BASE_URL = 'https://www.ycombinator.com/companies'

  def initialize(n, filters)
    @n = n
    @url = generate_url(filters)
    @options = Selenium::WebDriver::Chrome::Options.new(args: ['headless'])
    @driver = Selenium::WebDriver.for(:chrome, options: @options)
  end

  def generate_url(filters)
    return BASE_URL if filters.empty?

    mapped_params = {
      'batch' => filters['batch'],
      'industry' => filters['industry'],
      'isHiring' => filters['is_hiring'],
      'nonprofit' => filters['nonprofit'],
      'highlight_black' => filters['black_founded'],
      'highlight_women' => filters['women_founded'],
      'regions' => filters['region'],
      'team_size' => team_size_param(filters['company_size']),
      'tags' => filters['tag']
    }

    # Remove false values
    mapped_params.delete_if { |_, v| v.nil? || v == false }

    # Building the query parameters string
    query_params = URI.encode_www_form(mapped_params.compact)
    "#{BASE_URL}?#{query_params}"
  end

  def team_size_param(team_size)
    if team_size =~ /\A(\d+)-(\d+)\z/
      "[\"#{$1}\",\"#{$2}\"]"
    else
      team_size
    end
  end

  def scrape
    p "Scraping #{@n} companies from #{@url}"
    @driver.get(@url)
    wait = Selenium::WebDriver::Wait.new(timeout: 10)

    # Wait until the results container is present or a message indicating no results is found
    wait.until do
      @driver.find_element(css: '._results_86jzd_326') ||
        @driver.page_source.include?('Sorry, no matching companies found')
    end

    # Check if no companies are found after waiting for the page to load
    if @driver.page_source.include?('Sorry, no matching companies found')
      @driver.quit
      return []
    end

    companies = []

    while companies.size < @n
      page = Nokogiri::HTML(@driver.page_source)
      company_links = page.css('a._company_86jzd_338')

      company_links.each do |link|
        break if companies.size >= @n

        company_data = company_info(link)

        companies << company_data if company_data
      end

      # Scroll down to load more companies
      @driver.execute_script('window.scrollTo(0, document.body.scrollHeight);')
      sleep(2)
    end

    @driver.quit
    companies.uniq
  end

  private

  def scrape_company(path)
    httparty = HTTParty.get("https://www.ycombinator.com#{path}")
    page = Nokogiri::HTML(httparty.body)
    founder_names, founder_linkedin_urls = founder_info(page)

    {
      website: page.at_css('div.text-linkColor a[href^="http"]')&.text&.gsub("\u00A0", ' ')&.strip,
      founders: founder_names,
      linkedin_urls: founder_linkedin_urls
    }
  end

  def founder_info(page)
    founders = page.css('div.space-y-5 div.items-start')
    founder_names = founders.map { |founder| founder.css('h3.text-lg').map(&:text) }.flatten
    founder_linkedin_urls = founders.map { |founder| founder.css('a[href*="linkedin.com"]').map { |a| a['href'] } }.flatten

    [founder_names, founder_linkedin_urls]
  end

  def company_info(link)
    company_data = {
      name: link.at_css('span._coName_86jzd_453').text.strip,
      location: link.at_css('span._coLocation_86jzd_469')&.text&.strip,
      description: link.at_css('span._coDescription_86jzd_478')&.text&.strip,
      batch: link.at_css('a._tagLink_86jzd_1023 span.pill')&.text&.strip
    }
    company_data.merge(scrape_company(link['href']))
  end
end
