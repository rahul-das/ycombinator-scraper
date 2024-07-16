# Y Combinator Scraper API

This repository contains a web scraping API to extract data from Y Combinator's publicly listed companies. The API allows users to scrape a specified number of companies and filter results based on various criteria such as batch, industry, region, and founder demographics.

## Features

- Scrape detailed information about companies listed on Y Combinator.
- Apply multiple filters to narrow down the results.
- Extract information from both the main and detailed pages of each company.
- Output data in CSV format for easy analysis and storage.

## Installation

### Prerequisites

- Ruby (preferably version 2.6 or later)
- Bundler
- Google Chrome
- ChromeDriver

### Setup

1. **Clone the repository**:

    ```sh
    git clone https://github.com/rahul-das/ycombinator-scraper.git
    cd ycombinator-scraper
    ```

2. **Install dependencies**:

    ```sh
    bundle install
    ```

3. **Run the Sinatra server**:

    ```sh
    ruby app.rb
    ```

4. **Access the API**:
    Open your browser or use a tool like `curl` or Postman to interact with the API at `http://localhost:4567`.

## Live API

The live API is deployed at `http://54.91.165.230:4567/scrape`.

## Usage

### API Endpoints

1. **Scrape Data**
   - **Endpoint**: `/scrape`
   - **Method**: `POST`
   - **Content-Type**: `application/json`
   - **Request Body Examples**:

#### Example 1: Scraping 10 companies without filters

   ```sh
   curl --location 'http://54.91.165.230:4567/scrape' \
   --header 'Content-Type: application/json' \
   --data '{
       "n": 10,
       "filters": {}
   }'
   ```

   **Response Example**:

   ```json
   {
       "status": "success",
       "csv": "name,location,description,batch,website,founders,linkedin_urls\nAirbnb,\"San Francisco, CA, USA\",Book accommodations around the world.,W09,http://airbnb.com,\"Brian Chesky, CEO, Nathan Blecharczyk, CTO, Joe Gebbia, CPO\",\"https://www.linkedin.com/in/brianchesky/, https://www.linkedin.com/in/blecharczyk/, https://www.linkedin.com/in/jgebbia/\"\n..."
   }
   ```

#### Example 2: Scraping 10 healthcare companies from S21 batch in the USA

   ```sh
   curl --location 'http://54.91.165.230:4567/scrape' \
   --header 'Content-Type: application/json' \
   --data '{
       "n": 10,
       "filters": {
           "batch": "S21",
           "industry": "Healthcare",
           "region": "United States of America",
           "company_size": "1-10",
           "is_hiring": true,
           "nonprofit": false,
           "black_founded": true,
           "hispanic_latino_founded": false,
           "women_founded": true
       }
   }'
   ```

   **Response Example**:

   ```json
   {
       "status": "success",
       "csv": "name,location,description,batch,website,founders,linkedin_urls\nAgapé,\"Rochester, NY, USA\",\"Feel close, even when apart. One meaningful conversation at a time.\",S21,https://www.getdailyagape.com,\"Kadie Okwudili, Ron Rogge\",https://www.linkedin.com/in/khadeshaokwudili\n"
   }
   ```

### Filters

The API supports the following filters:

- `batch`: The Y Combinator batch (e.g., W21, S21).
- `industry`: The industry of the companies.
- `region`: The region where the companies are located.
- `company_size`: The size of the companies (e.g., 1-10, 11-50).
- `is_hiring`: Boolean indicating if the company is hiring.
- `nonprofit`: Boolean indicating if the company is a nonprofit.
- `black_founded`: Boolean indicating if the company is black-founded.
- `hispanic_latino_founded`: Boolean indicating if the company is Hispanic & Latino-founded.
- `women_founded`: Boolean indicating if the company is women-founded.

### Example Request

```sh
curl -X POST http://localhost:4567/scrape \
-H "Content-Type: application/json" \
-d '{
  "n": 10,
  "filters": {
    "batch": "W21",
    "industry": "Healthcare",
    "region": "United States",
    "company_size": "1-10",
    "is_hiring": true,
    "nonprofit": false,
    "black_founded": true,
    "women_founded": true
  }
}'
```

### Example Response

```json
{
  "status": "success",
  "csv": "name,location,description,batch,website,founders,linkedin_urls\nCompany1,Location1,Description1,W21,website1.com,Founder1,Founder2,linkedin.com/in/founder1,linkedin.com/in/founder2\nCompany2,Location2,Description2,W21,website2.com,Founder3,linkedin.com/in/founder3\n..."
}
```

### CSV Output

The API returns a CSV string containing the scraped data, which includes the following columns:

- `name`: The company name.
- `location`: The company location.
- `description`: A short description of the company.
- `batch`: The YC batch the company was part of.
- `website`: The company's website.
- `founders`: Names of the company founders.
- `linkedin_urls`: LinkedIn URLs of the founders.

## Repository Content

- **`app.rb`**: Sinatra application file.
- **`scraper.rb`**: Contains the scraping logic.
- **`api.rb`**: Contains the API endpoints and csv conversion logic.
- **`Gemfile`**: Lists required gems.
- **`Gemfile.lock`**: Lock file for gems.

## Contact

For any inquiries or support, please contact [rahul.kr.das.27@gmail.com](mailto:rahul.kr.das.27@gmail.com).
