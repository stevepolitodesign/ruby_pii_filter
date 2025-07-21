require "mitie"
require "ostruct"

# Module for handling Personally Identifiable Information (PII) filtering.
module PII
  # Filters PII such as names, emails, phone numbers, SSNs, and credit cards from input text.
  class Filter
    # @return [Regexp] Matches 16-digit credit card numbers without delimiters.
    CREDIT_CARD_REGEX = /\b[3456]\d{15}\b/

    # @return [Regexp] Matches 16-digit credit card numbers with delimiters (space, dash, or plus).
    CREDIT_CARD_REGEX_DELIMITERS = /\b[3456]\d{3}[\s+-]\d{4}[\s+-]\d{4}[\s+-]\d{4}\b/

    # @return [Regexp] Matches email addresses with `@` or URL-encoded `%40`.
    EMAIL_REGEX = /\b[\w+.-]+(?:@|%40)[a-z\d-]+(?:\.[a-z\d-]+)*\.[a-z]+\b/i

    # @return [Regexp] Matches phone numbers in various formats.
    PHONE_REGEX = /\b(?:\+\d{1,2}\s)?\(?\d{3}\)?[\s+.-]\d{3}[\s+.-]\d{4}\b/

    # @return [Regexp] Matches U.S. Social Security numbers.
    SSN_REGEX = /\b\d{3}[\s+-]\d{2}[\s+-]\d{4}\b/

    # @param input [String] The text to filter.
    # @param ner_model [Mitie::NER] Named Entity Recognition model.
    def initialize(input:, ner_model: Mitie::NER.new("ner_model.dat"))
      @input = input
      @output = input.dup
      @ner_model = ner_model
      @doc = ner_model.doc(input)
      @mapping = {}
    end

    # Executes the filter process.
    #
    # @return [OpenStruct] Contains original `input`, filtered `output`, and replacement `mapping`.
    def call
      filter_input

      OpenStruct.new(input:, output:, mapping:)
    end

    private

    attr_reader :input, :ner_model, :doc
    attr_accessor :mapping, :output

    # @return [Array<String>] All email addresses found in the text.
    def email_addresses
      output.scan(EMAIL_REGEX)
    end

    # @return [Array<String>] All credit card numbers found.
    def credit_card_numbers
      output.scan(CREDIT_CARD_REGEX) + output.scan(CREDIT_CARD_REGEX_DELIMITERS)
    end

    # @return [Array<String>] All person names identified by the NER model.
    def names
      # TODO: Account for confidence score
      people = doc.entities.filter { it.fetch(:tag) == "PERSON" }

      people.map { it.fetch(:text) }
    end

    # @return [Array<String>] All phone numbers found.
    def phone_numbers
      output.scan(PHONE_REGEX)
    end

    # @return [Array<String>] All social security numbers found.
    def social_security_numbers
      output.scan(SSN_REGEX)
    end

    # Replaces matched values in the text with labeled placeholders.
    #
    # @param values [Array<String>] Values to replace.
    # @param label [String] Label to use in the placeholder.
    # @return [void]
    def filter(values, label:)
      # TODO: Account for duplicates. What if the value appears in multiple places?
      values.each.with_index(1) do |value, index|
        filter = "#{label}_#{index}"

        output.gsub! value, "[#{filter}]"
        mapping[filter.to_sym] = value
      end
    end

    # Runs all filtering operations.
    #
    # @return [void]
    def filter_input
      filter email_addresses, label: "EMAIL"
      filter credit_card_numbers, label: "CREDIT_CARD_NUMBER"
      filter names, label: "NAME"
      filter phone_numbers, label: "PHONE_NUMBER"
      filter social_security_numbers, label: "SOCIAL_SECURITY_NUMBER"
    end
  end
end
