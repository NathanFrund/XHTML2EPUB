require 'rubygems'
require 'yaml'

class OPFItem
  attr_accessor :id, :href
  
  def initialize(id, href)
    @id = id.downcase.gsub('-', '').gsub(/^[0-9]*/,'').gsub('!','')
    @href = href
    
    @CONFIG = YAML.load_file('media_types.yml')
  end
  
  def media_type
    media_types = @CONFIG['types']
    media_types[href.split('.')[-1]]
  end
  
  def path_prefix
    file_type = href.split('.')[-1]
    prefix = "Text/" if file_type == 'xhtml'
    prefix = "Images/" if file_type == 'png'
    prefix = "Styles/" if file_type == 'css'
    return prefix
  end
  
  def to_manifest_item
    markup = "<item id=\"#{@id}\" href=\"#{path_prefix()}#{@href}\" media-type=\"#{media_type}\"/>"
  end
  
  def to_spine_itemref
    markup = "<itemref idref=\"#{@id}\" linear=\"yes\"/>"
  end
end