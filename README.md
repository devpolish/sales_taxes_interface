# Sales Taxes

Classify products based in whole sentences, products belong to medical, food or books categories are exempt of 10% tax, a tax of 5% is applied to every single product without not exceptions.

## Usage

```ruby
  require_relative 'lib/appraiser'
  appraiser = Appraiser.new(INPUT_PATHNAME)
  # Change default pathname output (default is 'output.csv')
  appraiser.file_output(PATHNAME)
  appraiser.appraise
```
