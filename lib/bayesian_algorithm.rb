# frozen_string_literal: true

# This is a customized version of https://github.com/reddavis/Naive-Bayes
# https://github.com/devpolish/Naive-Bayes
class NaiveBayes
  def initialize(*klasses)
    @features_count = {}
    @klass_count = {}
    @klasses = klasses

    klasses.each do |klass|
      @features_count[klass] = Hash.new(0.0)
      @klass_count[klass] = 0.0
    end
  end

  def train(klass, *features)
    features.uniq.each do |feature|
      @features_count[klass][feature] += 1
    end
    @klass_count[klass] += 1
  end

  def untrain(klass, *features)
    features.uniq.each do |feature|
      @features_count[klass][feature] -= 1
    end
    @klass_count[klass] -= 1
  end

  # P(Class | Item) = P(Item | Class) * P(Class)
  def classify(*features)
    scores = {}
    @klasses.each do |klass|
      scores[klass] = (prob_of_item_given_a_class(features, klass) * prob_of_class(klass))
    end
    return [] if scores.values.reduce(:+) == 0.0

    scores.min { |a, b| b[1] <=> a[1] }
  end

  private

  # P(Item | Class)
  def prob_of_item_given_a_class(features, klass)
    features.inject(1.0) do |sum, feature|
      prob_of_feature_given_a_class(feature, klass)
    end
  end

  # P(Feature | Class)
  def prob_of_feature_given_a_class(feature, klass)
    # If there is not any sentence in our trained models we return nil value
    @feature = @features_count[klass][feature.to_sym]
    feature.nil? ? feature : @features_count[klass][feature.to_sym] / @klass_count[klass]
  end

  # P(Class)
  def prob_of_class(klass)
    @klass_count[klass] / total_items
  end

  def total_items
    @klass_count.inject(0) do |sum, klass|
      sum += klass[1]
    end
  end
end
