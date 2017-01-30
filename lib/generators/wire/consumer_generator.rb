require "rails/generators/named_base"

module Wire
  module Generators
    class ConsumerGenerator < ::Rails::Generators::NamedBase
      check_class_collision suffix: "Consumer"

      def self.default_generator_root
        File.dirname(__FILE__)
      end

      def create_consumer_file
        template "consumer.rb.erb", File.join("app/consumers", class_path, "#{file_name}_consumer.rb")
      end
    end
  end
end
