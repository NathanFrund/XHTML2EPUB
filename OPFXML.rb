require 'rubygems'
require 'nokogiri'

require 'OPFItem'

module OPFXML
  private
  def self.add_to_content_opf(item)
    result = @manifest_doc.css("item##{item.id}")
    @manifest_doc.at_css("manifest") << item.to_manifest_item if result.count == 0
    if(item.media_type == 'application/xhtml+xml')
      @manifest_doc.at_css("spine") << item.to_spine_itemref if result.count == 0
    end
  end

  def self.write_content_opf
    manifest_file = File.new(@epub_directory + "/OEBPS/content.opf", "w")
    manifest_file.write(@manifest_doc)
    manifest_file.close
  end
  
  def self.catalog_xhtml_items
    path = @epub_directory + "/OEBPS/Text/[0-9][0-9]*.xhtml"
    list = Array.new
    Dir.glob(path).each do |file|
      href = file.split('/')[-1]
      id = href.slice(3...href.length).split('.')[0]
      item = OPFItem.new(id, href)
      add_to_content_opf(item)
    end
    write_content_opf()
  end
  
  def self.catalog_png_items
    path = @epub_directory + "/OEBPS/Images/*.png"
    list = Array.new
    Dir.glob(path).each do |png|
      href = png.split('/')[-1]
      id = href.split('.')[0]
      item = OPFItem.new(id, href)
      add_to_content_opf(item)
    end
    write_content_opf()
  end
    
  public
  def self.set_title(master_html_path, epub_directory)
    html = Nokogiri::XML(open(master_html_path))
    @manifest_doc = Nokogiri::XML(open(epub_directory + "/OEBPS/content.opf"))
    
    html_title_element = html.at_css('html head title')
    
    opf_title_elements = @manifest_doc.xpath('//dc:title', 'dc' => 'http://purl.org/dc/elements/1.1/')
    opf_title_elements[0].content = html_title_element.content
    self.write_content_opf()
  end
  
  def self.set_author(master_html_path, epub_directory)
    html = Nokogiri::XML(open(master_html_path))
    @manifest_doc = Nokogiri::XML(open(epub_directory + "/OEBPS/content.opf"))
    
    opf_metadata = @manifest_doc.css('package metadata')
    creator_element = opf_metadata.xpath('//dc:creator', 'dc' => 'http://purl.org/dc/elements/1.1/')[0]
    
    html_author_elements = html.css('html head meta[name="author"]')
    
    html_author_elements.each do |html_element|
      author_name = html_element['content']
      xpath_selector = "//dc:creator[text() = '#{author_name}']"
      check_element = opf_metadata.xpath(xpath_selector, 'dc' => 'http://purl.org/dc/elements/1.1/')[0]
      
      if check_element.nil?
        cloned_creator_element = creator_element.clone
        cloned_creator_element.content = html_element['content']
        opf_metadata.children.before(cloned_creator_element)
      end
       
    end
    
    creator_element.remove() if opf_metadata.xpath('//dc:creator', 'dc' => 'http://purl.org/dc/elements/1.1/')[0].content == ""
    self.write_content_opf()
  end
  
  def self.set_uuid(uuid, epub_directory)
    @manifest_doc = Nokogiri::XML(open(epub_directory + "/OEBPS/content.opf"))
    opf_metadata = @manifest_doc.css('package metadata')
    identifier_element = opf_metadata.xpath('//dc:identifier', 'dc' => 'http://purl.org/dc/elements/1.1/')[0]
    identifier_element.content = uuid
    self.write_content_opf()
  end
  
  def self.catalog_opf_items(epub_directory)
    @epub_directory = epub_directory
    @manifest_doc = Nokogiri::XML(open(@epub_directory + "/OEBPS/content.opf"))
    self.catalog_xhtml_items()
    self.catalog_png_items()
  end
end