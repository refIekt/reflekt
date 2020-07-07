module Reflekt

  def initialize(*args)
    puts "Constructor."
    super
  end

  def display(amount = nil)

    puts "Override."

    # Limit amount of results.
    if (amount)
      ngrams = @ngrams.first(amount)
    else
      ngrams = @ngrams
    end
    # Display ngrams.
    ngrams.each do |ngram, count|
      percentage = ''
      unless @percentages[ngram].nil?
        percentage = " (" + (@percentages[ngram] * 100).round(2).to_s + "%)"
      end
      puts ngram + " (" + count.to_s + ")" + percentage
    end
  end

end
