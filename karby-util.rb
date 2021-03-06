require 'fileutils'

PRE_AGGREGATION_DIR = (ENV.include?('PRE_AGGREGATION_DIR') ? ENV['PRE_AGGREGATION_DIR'] : './temp')
FileUtils.mkdir_p PRE_AGGREGATION_DIR unless File.exists?(PRE_AGGREGATION_DIR)

POST_AGGREGATION_DIR = (ENV.include?('POST_AGGREGATION_DIR') ? ENV['POST_AGGREGATION_DIR'] : './logs')
FileUtils.mkdir_p POST_AGGREGATION_DIR unless File.exists?(POST_AGGREGATION_DIR)

class DatedFile
  attr_reader :path, :creation_date

  def initialize path, creation_date
    @path = path
    @creation_date = creation_date
  end

  def to_s
    "#{path} was created #{@creation_date}"
  end
end
