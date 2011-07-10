require 'rubygems'
require 'fileutils'

module EPUBFilesystem
  def EPUBFilesystem.create_destination_directory(path)
    Dir.mkdir(path) unless File.exists?(path)
    
    FileUtils.cp_r('epub_template/META-INF', path) unless File.exists?("#{path}/META-INF")
    FileUtils.cp_r('epub_template/OEBPS', path) unless File.exists?("#{path}/OEBPS")
    FileUtils.cp('epub_template/mimetype', path)
  end
 
  def EPUBFilesystem.copy_pngs(master_directory, epub_directory)
    path = master_directory + "/*.png"
    Dir.glob(path).each do |png|
      FileUtils.cp(png, epub_directory + "/OEBPS/Images")
    end
  end 
  
end