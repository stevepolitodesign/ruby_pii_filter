# Ruby PII Filter

This is a proof of concept.

Creates an interface for filtering personally identifiable information (PII)
from free text, before sending it to external services our APIs, such as
Chatbots.

The majority of the filtering is supported by regular expressions, which were
lifted from [logstop][1].

However, filtering names is more nuanced, and required [MITIE Ruby][2]. This
means there's a dependency on a [pre-trained model][3]. This project assumes it
lives alongside `pii_filter.rb`, but that is not a requirement.

[1]: https://github.com/ankane/logstop/blob/a44fe2d808444f6ad266ae7d3065bce386381619/lib/logstop.rb#L10-L18
[2]: https://github.com/ankane/mitie-ruby
[3]: https://github.com/mit-nlp/MITIE/releases/download/v0.4/MITIE-models-v0.2.tar.bz2
