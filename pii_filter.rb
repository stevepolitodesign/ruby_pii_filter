require "mitie"
require "ostruct"

module PII
  class Filter
    CREDIT_CARD_REGEX = /\b[3456]\d{15}\b/
    CREDIT_CARD_REGEX_DELIMITERS = /\b[3456]\d{3}[\s+-]\d{4}[\s+-]\d{4}[\s+-]\d{4}\b/
    EMAIL_REGEX = /\b[\w+.-]+(?:@|%40)[a-z\d-]+(?:\.[a-z\d-]+)*\.[a-z]+\b/i
    PHONE_REGEX = /\b(?:\+\d{1,2}\s)?\(?\d{3}\)?[\s+.-]\d{3}[\s+.-]\d{4}\b/
    SSN_REGEX = /\b\d{3}[\s+-]\d{2}[\s+-]\d{4}\b/

    def initialize(input:, ner_model: Mitie::NER.new("ner_model.dat"))
      @input = input
      @output = input.dup
      @ner_model = ner_model
      @doc = ner_model.doc(input)
      @mapping = {}
    end

    def call
      filter_input

      OpenStruct.new(input:, output:, mapping:)
    end

    private

    attr_reader :input, :ner_model, :doc
    attr_accessor :mapping, :output

    def email_addresses
      output.scan(EMAIL_REGEX)
    end

    def credit_card_numbers
      output.scan(CREDIT_CARD_REGEX) + output.scan(CREDIT_CARD_REGEX_DELIMITERS)
    end

    def names
      # TODO: Account for confidence score
      people = doc.entities.filter { it.fetch(:tag) == "PERSON" }

      people.map { it.fetch(:text) }
    end

    def phone_numbers
      output.scan(PHONE_REGEX)
    end

    def social_security_numbers
      output.scan(SSN_REGEX)
    end

    def filter(values, label:)
      # TODO: Account for duplicates. What if the value appears in multiple places?
      values.each.with_index(1) do |value, index|
        filter = "#{label}_#{index}"

        output.gsub! value, "[#{filter}]"
        mapping[filter.to_sym] = value
      end
    end

    def filter_input
      filter email_addresses, label: "EMAIL"
      filter credit_card_numbers, label: "CREDIT_CARD_NUMBER"
      filter names, label: "NAME"
      filter phone_numbers, label: "PHONE_NUMBER"
      filter social_security_numbers, label: "SOCIAL_SECURITY_NUMBER"
    end
  end
end

input = <<~FREE_TEXT
  Martin Westport can be reached at 202-918-2132, and Erin Meadowbrook can be reached at erin@gmail.com.
  Harper Winter's SSN is 766-96-2016, and her credit card is 4242-4242-4242-4242, but she also uses 4141414141414141.
FREE_TEXT

result = PII::Filter.new(input:).call

pp result.input
pp result.output
pp result.mapping
