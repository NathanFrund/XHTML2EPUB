module EPUBZIP
  def self.zipit(epub_file_name, epub_directory, zip_to_directory)
    result = `cd #{epub_directory}; 
              zip -X #{zip_to_directory}/#{epub_file_name} mimetype
              zip -rg #{zip_to_directory}/#{epub_file_name} META-INF -x \*.DS_Store; 
              zip -rg #{zip_to_directory}/#{epub_file_name} OEBPS -x \*.DS_Store`
    puts result
  end
end