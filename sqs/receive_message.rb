#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

require "rubygems"
require "aws-sdk"
require File.join(File.dirname(__FILE__), "../samples_config")
require File.join(File.dirname(__FILE__), "upload_file")
require "pp"
require "yaml"

AMAZON_SQS_TEST_QUEUE = "SQS-Test-Queue-Ruby"


def image_correction(s)
  str = ""
  status = s.dup
  message = status[:correction]
  b = message[:bucket_name]
  temp = "tmp/tempfile_#{b}.txt"

  download_file(b, message[:file_name], temp)

  File.open(temp, "r") do |f|
    str = f.read
  end

  correction_file = "tmp/correction_#{b}.txt"
  File.open(correction_file, "w") do |f|
    f.write(str.reverse)
  end

  upload_file(b, correction_file)

  status[:correction][:status] = "done"
  status[:process] = { :status => "todo",
                       :bucket_name => b,
                       :file_name => correction_file.gsub(/tmp\//,"")}
  status
end

def image_process(s)
  str = ""
  status = s.dup
  message = status[:process]
  b = message[:bucket_name]
  temp = "tmp/tempfile_#{b}.txt"

  download_file(b, message[:file_name], temp)

  File.open(temp, "r") do |f|
    str = f.read
  end

  image_file = "tmp/image_process_#{b}.txt"
  File.open(image_file, "w") do |f|
    f.write(str.upcase)
  end

  upload_file(b, image_file)

  status[:process][:status] = "done"
  status
end

sqs = AWS::SQS.new
queue = sqs.queues.named(AMAZON_SQS_TEST_QUEUE)

puts "**************************"
puts `date`
puts "**************************"

22.times do |i|
  sleep 3
  puts "waiting message"
  m = queue.receive_message
  if !m.nil?
    mbody = JSON.parse(m.body)
    yaml_file = File.join(File.dirname(__FILE__), "tmp/#{mbody['content_id']}.yml")
    status = YAML.load_file(yaml_file)
    puts "***#{status[:time]}番目のメッセージを処理する***"
    puts "message body: #{status}"

    new_status = if status[:correction][:status] == "todo"
                   result = image_correction(status)
                   queue.send_message(m.body)
                   result
                 elsif status[:process][:status] == "todo"
                   image_process(status)
                 else
                   nil
                 end

    File.open(yaml_file, "w") do |f|
      f.write(YAML.dump(new_status))
    end

    puts "delete message"
    m.delete
  end
end


