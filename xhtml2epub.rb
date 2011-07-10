require 'rubygems'
require 'nokogiri'
require 'yaml'

require 'EPUBFilesystem'
require 'XHTMLProcessor'
require 'OPFXML'
require 'TOCXML'
require 'EPUBZIP'
require 'UniqueID'

CONFIG = YAML.load_file('configuration.yml');

master_directory = CONFIG['master_directory']
master_file_name = CONFIG['master_file_name']
multimarkdown_file_name = CONFIG['multimarkdown_file_name']
epub_directory = CONFIG['epub_directory']
epub_file_name = CONFIG['epub_file_name']
zip_to_directory = CONFIG['zip_to_directory']

# Create the EPUB working directory.
EPUBFilesystem.create_destination_directory(epub_directory)
EPUBFilesystem.copy_pngs(master_directory,epub_directory)

# Assemble the path trings for munging the XHTML
master_file_full_path = master_directory + "/" + master_file_name
epub_text_directory = epub_directory + "/OEBPS/Text"

# Process the XHTML.
XHTMLProcessor.split_chapters(master_file_full_path, epub_text_directory)
XHTMLProcessor.process_links(epub_text_directory)
XHTMLProcessor.enforce_valid_ids(epub_text_directory)
XHTMLProcessor.remove_images_from_figures(epub_text_directory)
XHTMLProcessor.markup_level_elements(epub_text_directory)

# Determine the UUID for the EPUB
uuid = UniqueID.get

# Generate the content.opf file.
OPFXML.catalog_opf_items(epub_directory)
OPFXML.set_title(master_file_full_path, epub_directory)
OPFXML.set_uuid(uuid, epub_directory)
OPFXML.set_author(master_file_full_path, epub_directory)

# Generate the toc.ncx file.
TOCXML.add_chapters_to_toc(epub_directory)
TOCXML.set_uuid(uuid, epub_directory)

# Zip it all up.
EPUBZIP.zipit(epub_file_name, epub_directory, zip_to_directory)