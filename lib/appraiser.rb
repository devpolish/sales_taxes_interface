# frozen_string_literal: true

# Load files from lib folder automatically
lib = File.expand_path(__dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'csv'
require 'yaml'
require 'modules/classifier'

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
    @file.collect! do |product|
      total_tax = 0.0
      total_tax += calculate_percentage(10, product[2]) unless product_is_exempt?(product[1])
      total_tax += calculate_percentage(5, product[2])
      product.concat([total_tax])
    end
    save_report('output.csv')
  end

  def save_report(pathname)
    CSV.open(pathname, 'wb') do |csv|
      # Add extra column without unfrezee array
      @file.each { |row| csv << row }
    end
  rescue Errno::ENOENT => exception
    exception.class
  end

  def calculate_percentage(pct, price)
    (price.to_f * pct) / 100.00
  end

  private

  def product_is_exempt?(product_name)
    classification = classify(models, product_name)
    EXEMPT_CATEGORIES.include?(classification.first)
  end
end
