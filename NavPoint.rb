class NavPoint
  attr_accessor :id, :play_order, :text, :source
  
  def initialize(id, play_order, text, source)
    @id = id
    @play_order = play_order
    @text = text
    @source = source
  end
  
  def markup
    markup = "
      <navPoint id=\"navPoint-#{@play_order}\" playOrder=\"#{@play_order}\">
  			<navLabel>
  				<text>#{@text}</text>
  			</navLabel>
  			<content src=\"Text/#{@source}\"/>
  		</navPoint>
    "
  end
end