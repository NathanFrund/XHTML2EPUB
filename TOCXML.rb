require 'rubygems'
require 'nokogiri'

require 'NavPoint'

module TOCXML
  private
  def self.get_text(file)
    @doc = Nokogiri::XML(open(file))
    text = @doc.css('h1').inner_html
  end
  
  def self.insert_navpoint(nav_point)
    result = @toc_doc.css("navPoint##{nav_point.id}")
    @toc_doc.at_css('navMap') << nav_point.markup if result.count == 0
  end
    
  def self.nav_point_list
    path = @epub_directory + "/OEBPS/Text/[0-9][0-9]*.xhtml"
    list = Array.new
    Dir.glob(path).each_with_index do |file, index|
      text = get_text(file)
      source= file.split('/')[-1]
      play_order = source.split('-')[0]
      play_order = play_order[1,2] if play_order[0,1] == '0'
      id = "navPoint-#{play_order}"
      
      nav_point = NavPoint.new(id, play_order, text, source)
      
      list[index] = nav_point
    end
    return list
  end
  public
  def self.add_chapters_to_toc(epub_directory)
    @epub_directory = epub_directory
    @toc_doc = Nokogiri::XML(open(@epub_directory + "/OEBPS/toc.ncx"))
    
    nav_point_list.each do |nav_point|
      self.insert_navpoint(nav_point)
    end
    
    toc_file = File.new(@epub_directory + "/OEBPS/toc.ncx", "w")
    toc_file.write(@toc_doc)
    toc_file.close
  end
end