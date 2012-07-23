#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

require "rubygems"
require "aws-sdk"
require File.join(File.dirname(__FILE__), "samples_config")
require File.join(File.dirname(__FILE__), "upload_file")

AMAZON_SQS_TEST_QUEUE = "Process-SQS-Test-Queue"


def image_process(message)
  str = ""
  b = message["bucket_name"]
  fn = message["file_name"]
  temp = "tmp/tempfile_#{b}.txt"

  download_file(b, fn, temp)

  File.open(temp, "r") do |f|
    str = f.read
  end

  image_file = "tmp/image_process_#{b}.txt"
  File.open(image_file, "w") do |f|
    f.write(str.upcase)
  end

  upload_file(b, image_file)

  image_file
end

sqs = AWS::SQS.new
queue = sqs.queues.named(AMAZON_SQS_TEST_QUEUE)

20.times do |i|
  sleep 3
  puts "waiting message in 3 seconds"
  m = queue.receive_message
  if !m.nil?
    mbody = JSON.parse(m.body)
    puts "***#{mbody['time']}番目のメッセージを処理する***"
    puts "message body: #{m.body}"

    image_process(mbody)
    m.delete
  end
end


