# Ruby PII Filter

This is a proof of concept.

Creates an interface for filtering personally identifiable information (PII)
from free text, before sending it to external services or APIs, such as
Chatbots.

The majority of the filtering is supported by regular expressions, which were
lifted from [logstop][1].

However, filtering names is more nuanced, and required [MITIE Ruby][2]. This
means there's a dependency on a [pre-trained model][3]. This project assumes it
lives alongside `pii_filter.rb`, but that is not a requirement.

## Examples

```ruby
require "pii/filter"

input = <<~TEXT
  Martin Westport can be reached at 202-918-2132, and Erin Meadowbrook can be reached at erin@gmail.com.
  Harper Winter's SSN is 766-96-2016, and her credit card is 4242-4242-4242-4242, but she also uses 4141414141414141.
TEXT

result = PII::Filter.new(input:).call

puts result.input
# => Original unfiltered text

puts result.output
# => Filtered text with PII replaced:
#    "[NAME_1] can be reached at [PHONE_NUMBER_1], and [NAME_2] can be reached at [EMAIL_1].
#     [NAME_3]'s SSN is [SOCIAL_SECURITY_NUMBER_1], and her credit card is [CREDIT_CARD_NUMBER_1],
#     but she also uses [CREDIT_CARD_NUMBER_2]."

puts result.mapping
# => {
#      :NAME_1 => "Martin Westport",
#      :PHONE_NUMBER_1 => "202-918-2132",
#      :NAME_2 => "Erin Meadowbrook",
#      :EMAIL_1 => "erin@gmail.com",
#      :NAME_3 => "Harper Winter",
#      :SOCIAL_SECURITY_NUMBER_1 => "766-96-2016",
#      :CREDIT_CARD_NUMBER_1 => "4242-4242-4242-4242",
#      :CREDIT_CARD_NUMBER_2 => "4141414141414141"
#    }
```

[1]: https://github.com/ankane/logstop/blob/a44fe2d808444f6ad266ae7d3065bce386381619/lib/logstop.rb#L10-L18
[2]: https://github.com/ankane/mitie-ruby
[3]: https://github.com/mit-nlp/MITIE/releases/download/v0.4/MITIE-models-v0.2.tar.bz2
