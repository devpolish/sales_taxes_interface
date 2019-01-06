# frozen_string_literal: true

# Load files from lib folder automatically
lib = File.expand_path(__dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'csv'
require 'yaml'
require 'modules/classifier'

# Appraiser class taxes all products and save them into a CSV file.
class Appraiser
  HEADERS = %w[quantity product price taxes].freeze
  EXEMPT_CATEGORIES = %w[medical food books].freeze
  include Classifier

  attr_reader :models
  attr_writer :file_output

  def initialize(pathname, file_output = 'output.csv')
    @file = CSV.read(pathname)
    @models = YAML.safe_load(File.read('models/train.yml'))
    @file_output = file_output
  end

  def appraise
    @file.collect! do |row|
      product = key_extractor(row)
      total_tax = 0.0
      total_tax += calculate_percentage(10, product[:price] * product[:qty]) unless product_is_exempt?(product[:name])
      total_tax += calculate_percentage(5, product[:price] * product[:qty])
      row.concat([total_tax])
    end
    @file.push(['Sales Taxes', @file.map(&:last).reduce(:+)])
    @file.push(['Total', total_price])
    save_report
  end

  def save_report
    CSV.open(@file_output, 'wb') do |csv|
      csv << HEADERS
      @file.each { |row| csv << row }
    end
  rescue Errno::ENOENT => exception
    exception.class
  end

  def calculate_percentage(pct, price)
    (price.to_f * pct) / 100.00
  end

  private

  def key_extractor(product)
    {
      qty: product[0].to_i,
      name: product[1],
      price: product[2].to_f
    }
  end

  # Sum all normal prices with their respectives taxes
  def total_price
    @file.map { |f| f[2..3].map(&:to_f) }.flatten.reduce(:+)
  end

  def product_is_exempt?(product_name)
    classification = classify(models, product_name)
    EXEMPT_CATEGORIES.include?(classification.first)
  end
end
