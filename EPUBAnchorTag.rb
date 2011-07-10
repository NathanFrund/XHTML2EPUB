require 'rubygems'
require 'nokogiri'
require 'yaml'

class EPUBAnchorTag
  
  def initialize(node)
    @href = node['href']
    @CONFIG = YAML.load_file('configuration.yml')
    @epub_directory = @CONFIG["epub_directory"]
  end
  
  def target_id
    @href[1..@href.length]
  end
  
  def is_internal_link?
    @href.slice(0,1) == "#"
  end
  
  def is_external_link?
    @href.include?('://')
  end
  
  def target_document
    directory = Dir.glob(@epub_directory + "/OEBPS/Text/*.xhtml")
    
    directory.each do |filename|
      doc = Nokogiri::XML(open(filename))
      header = doc.at_css("h1")
      return filename if header['id'] == target_id
    end
  end
  
end