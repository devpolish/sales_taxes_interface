# frozen_string_literal: true

require 'bayesian_algorithm'

# Provides a helper method to classify words from a sentence
# This module uses a a simple probabilitic classifier called Bayes's theorem
# Natutal Language Processing is how machines can understand to human idioms)
module Classifier
  def classify(models, sentence)
    classifier = NaiveBayes.new(*models.keys)
    models.map { |k, arr| classifier.train(k, *arr.map(&:to_sym)) }
    classifier.classify(*sentence.split(' '))
  end
end
