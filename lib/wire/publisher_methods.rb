module Wire
  module PublisherMethods
    extend ActiveSupport::Concern

    included do
      cattr_accessor :publish_attributes
      after_commit :sync_changed, if: -> { (previous_changes.keys & self.class.publish_attributes).any? || destroyed? }
    end

    def sync_changed
      sync(attributes: previous_changes.keys)
    end

    def sync(attributes: nil)
      payload = {
        id: id
      }
      if destroyed?
        payload[:destroyed] = true
      else
        attributes ||= self.attributes.keys
        payload[:attributes] = self.attributes.slice(*(attributes & self.class.publish_attributes))
      end
      # use key to ensure updates go to same partition
      Wire.publish("#{self.class.name.underscore}_update", payload, key: id)
    end
  end
end
