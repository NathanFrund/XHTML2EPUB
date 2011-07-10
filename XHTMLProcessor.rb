require 'rubygems'
require 'nokogiri'

require 'EPUBAnchorTag.rb'

module XHTMLProcessor
  
  def self.sanitize(title)
    title = title.gsub(' ','')
    title = title.gsub('&amp;','')
    title = title.gsub(':','-')
    title = title.gsub('.','-')
  end
    
  def self.split_chapters(xhtml_doc, target_directory)
    @doc = Nokogiri::XML(open(xhtml_doc))
    @xhtml_template = @doc.clone.css("html").first
    content = @doc.css("html body").children.to_s
    
    chapters = content.split(/<hr\/>/)
    chapters.each_with_index do |chapter, index|
      
      index = index + 2
      if index < 10
        place = 0.to_s + index.to_s 
      else 
        place = index 
      end
      
      @xhtml_template.css("body").children.remove
    
      fragment = Nokogiri::XML.fragment(chapter)
      
      title = fragment.css('h1').inner_html
      title = XHTMLProcessor.sanitize(title)
      
      @xhtml_template.at_css("body") << fragment
      
      chapter_file = File.new(target_directory + "/#{place.to_s}-#{title}.xhtml", "w")
      chapter_file.write(@xhtml_template)
      chapter_file.close
    end
  end
  
  def self.process_links(chapters_path)
    chapters_path = chapters_path + "/*.xhtml"
    
    Dir.glob(chapters_path).each do |file|
      epub = Nokogiri::XML(open(file))
      anchor_tags = epub.css('a')
      
      anchor_tags.each do |a|
        anchor_tag = EPUBAnchorTag.new(a)
        if not anchor_tag.is_external_link?
          target = anchor_tag.target_document.split("/")[-1]
          a['href'] = target
        end
      end
      File.open(file, 'w') { |f| f.write(epub)}
    end
  end
  
  def self.enforce_valid_ids(chapters_path)
    chapters_path = chapters_path + "/*.xhtml"
    
    Dir.glob(chapters_path).each do |file|
      epub = Nokogiri::XML(open(file))
      
      elements = epub.css("*")
      elements.each do |element|
        id = element['id']
        if not id.nil?
          element['id'] = id.gsub(":",'')
        end
        
        if element.name == 'img'
          element['id'] = element['src'].split('/')[-1].split('.')[0]
        end
      end
      
      File.open(file, 'w') { |f| f.write(epub)}
    end
  end
  
  def self.remove_images_from_figures(chapters_path)
    chapters_path = chapters_path + "/*.xhtml"
    
    Dir.glob(chapters_path).each do |file|
      doc = Nokogiri::XML(open(file))
      figures = doc.search("figure")
      figures.each do |figure|
        image = figure.at_css("img")
        image['src'] = "../Images/#{image['src']}"
        image.parent.replace image
        image.replace(Nokogiri.make("<p>#{image.to_html}</p>"))
      end
      File.open(file, 'w') { |f| f.write(doc)}
    end
  end
  
  def self.assemble_levels_markup(levels, separator)
    markup = ""
    levels.each_with_index do |level, index|
      markup = markup + "<span class = '#{level.downcase.strip}'>#{level}</span>"
      if index != levels.count - 1
        markup = markup + " " + separator + " "
      end
    end
    return markup
  end
  
  def self.markup_level_elements(chapters_path)
    chapters_path = chapters_path + "/*.xhtml"
    
    Dir.glob(chapters_path).each do |file|
      epub = Nokogiri::XML(open(file))
      elements = epub.css("p")
      elements.each do |element|
        if element.content.include?('←') or element.content.include?('→')
          levels = element.content.split(/←|→/)
          arrow = element.content.scan(/←|→/)[0]
          adjusted_line =  assemble_levels_markup(levels, arrow)
          element.inner_html = adjusted_line
        end
      end
      File.open(file, 'w') { |f| f.write(epub)}
    end
  end

end