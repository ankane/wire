module Wire
  class Railtie < ::Rails::Railtie
    initializer "wire" do |app|
      Wire.app = ENV["WIRE_APP"] || app.class.parent_name.underscore
    end
  end
end
