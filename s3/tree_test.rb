require "rubygems"
require "aws-sdk"
require File.join(File.dirname(__FILE__), "../samples_config")
require "pp"
s3 = AWS::S3.new
b = s3.buckets[ENV['AWS_BUCKET']]
tree = b.as_tree(:prefix => '1')
pp tree.children.select(&:branch?).collect(&:prefix)
