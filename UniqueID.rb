require 'rubygems'
require 'uuidtools'

module UniqueID
  def self.get
    config = YAML.load_file('configuration.yml');
    uuid = config['epub_uid']
    uuid = UUIDTools::UUID.random_create if uuid.nil?
    uuid = "urn:uuid:#{uuid}"
  end
end