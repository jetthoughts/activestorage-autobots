[![Gem Version](https://badge.fury.io/rb/activestorage-autobots.svg)](https://rubygems.org/gems/activestorage-autobots)
[![Build](https://github.com/jetthoughts/activestorage-autobots/workflows/Build/badge.svg)](https://github.com/jetthoughts/activestorage-autobots/actions)

# ActiveStorage Autobots (aka ActiveStorage Transformers)

Enables ActiveStorage variants for other file types than images, such as audio or video files, through an API for registering custom transformers similar to previewers. An example `ffmpeg` transformation is provided.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'activestorage-autobots'
```

And then execute:

    $ bundle

## Usage

```ruby
# lib/active_storage/transformers/ffmpeg_transformer.rb

require 'active_storage/transformers/transformer'

class ActiveStorage::Transformers::FFMPEGTransformer < ActiveStorage::Transformers::Transformer
  def self.accept?(blob)
    blob.video? || blob.audio?
  end

  def transform(input, format:)
    format ||= File.extname(input.path)
    options = transformations[:ffmpeg_opts]
    create_tempfile(ext: format) do |output|
      system "ffmpeg -y -i #{input.path} #{options} #{output.path}", exception: true
      yield output
    end
  end

  def create_tempfile(ext: '')
    ext = ".#{ext}" unless ext.blank? || ext.start_with?('.')
    tempfile = Tempfile.new(['active_storage_transformer_', ext], binmode: true)
    yield tempfile
  ensure
    tempfile.close!
  end
end
```

Update in initializers
```ruby
# config/initializers/active_storage.rb

require 'active_storage/transformers/ffmpeg_transformer'

ActiveStorage.transformers << ActiveStorage::Transformers::FFMPEGTransformer
# => [ ActiveStorage::Transformers::ImageProcessingTransformer, FFMPEGTransformer ]
```

```html+erb
<%= audio_tag user.my_audio.variant(ffmpeg_opts: "-af silenceremove=stop_periods=-1:stop_duration=1:stop_threshold=-90dB", format: "mp3") %>
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jetthoughts/activestorage-autobots. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
