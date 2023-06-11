# frozen_string_literal: true

require "active_storage"
require "active_support"
require "active_support/rails"

module ActiveStorage
  mattr_accessor :transformers, default: [ActiveStorage::Transformers::ImageProcessingTransformer]

  module Autobots
    module RepresentableOverride
      def variable?
        ActiveStorage.transformers.any? { |klass| klass.accept?(self) }
      end

    end

    module VariantOverride
      def process
        blob.open do |input|
          variation.transform(blob, input) do |output|
            service.upload(key, output, content_type: content_type)
          end
        end
      end
    end

    module VariantWithRecordOverride
      def transform_blob
        blob.open do |input|
          variation.transform(blob, input) do |output|
            yield io: output, filename: "#{blob.filename.base}.#{variation.format.downcase}",
              content_type: variation.content_type, service_name: blob.service.name
          end
        end
      end
    end

    module VariationOverride
      def transform(blob, file, &block)
        ActiveSupport::Notifications.instrument("transform.active_storage") do
          transformer(blob).transform(file, format: format, &block)
        end
      end

      private

      def transformer(blob)
        transformer_class(blob).new(transformations.except(:format))
      end

      def transformer_class(blob)
        ActiveStorage.transformers.detect { |klass| klass.accept?(blob) }
      end
    end

    module ImageProcessingTransformerOverride
      def accept?(blob)
        ActiveStorage.variable_content_types.include?(blob.content_type)
      end
    end

    module VideoAnalyzerOverride
      def accept?(blob)
        # TODO: we should explicitly pass content type of the transformed files.
        #       Sometimes Marco could not able to detect from file name only, like we got for `video/mp4`.
        blob.video? || blob.content_type.end_with?("/mp4")
      end
    end
  end
end

ActiveSupport.on_load(:active_storage_blob) do
  ActiveStorage::Blob::Representable.prepend(ActiveStorage::Autobots::RepresentableOverride)
  ActiveStorage::Variant.send(:prepend, ActiveStorage::Autobots::VariantOverride)
  ActiveStorage::VariantWithRecord.send(:prepend, ActiveStorage::Autobots::VariantWithRecordOverride)
  ActiveStorage::Variation.send(:prepend, ActiveStorage::Autobots::VariationOverride)
  ActiveStorage::Analyzer::VideoAnalyzer.singleton_class.send(:prepend, ActiveStorage::Autobots::VideoAnalyzerOverride)
  ActiveStorage::Transformers::ImageProcessingTransformer.send(
    :extend, ActiveStorage::Autobots::ImageProcessingTransformerOverride
  )
end

require "active_storage/autobots/railtie" if defined?(Rails)
