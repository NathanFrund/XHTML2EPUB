require 'rubygems'
require 'yaml'

CONFIG = YAML.load_file('configuration.yml');

master_directory = CONFIG['master_directory']
master_file_name = CONFIG['master_file_name']
multimarkdown_file_name = CONFIG['multimarkdown_file_name']

full_path_to_mmd = "#{master_directory}/#{multimarkdown_file_name}"
full_path_to_xhtml = "#{master_directory}/#{master_file_name}"

result = `multimarkdown #{full_path_to_mmd} > #{full_path_to_xhtml}`