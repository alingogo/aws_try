#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

require "rubygems"
require "aws-sdk"
require File.join(File.dirname(__FILE__), "../samples_config")
require File.join(File.dirname(__FILE__), "upload_file")
require "pp"

AMAZON_SQS_TEST_QUEUE = "SQS-Test-Queue-Ruby"
SQS_TEST_MESSAGE = 'This is a test message.'


def image_correction(message, q)
  str = ""
  b = message["bucket_name"]
  temp = "tmp/tempfile_#{b}.txt"

  download_file(b, message["file_name"], temp)

  File.open(temp, "r") do |f|
    str = f.read
  end

  correction_file = "tmp/correction_#{b}.txt"
  File.open(correction_file, "w") do |f|
    f.write(str.reverse)
  end

  upload_file(b, correction_file)
  fn = correction_file.gsub(/tmp\//,"")

  message['type'] = "process"
  message['file_name'] = fn
  sent_message = q.send_message(message.to_json)
  puts "message_id: " + sent_message.message_id
end

def image_process(message)
  str = ""
  b = message["bucket_name"]
  temp = "tmp/tempfile_#{b}.txt"

  download_file(b, message["file_name"], temp)

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


puts "**************************"
puts `date`
puts "**************************"

20.times do |i|
  sleep 3
  puts "waiting message in 3 seconds"
  m = queue.receive_message
  if !m.nil?
    mbody = JSON.parse(m.body)
    puts "***#{mbody['time']}番目のメッセージを処理する***"
    puts "message body: #{m.body}"

    case mbody['type']
    when 'correction'
      image_correction(mbody, queue)
    when 'process'
      image_process(mbody)
    else
      puts "処理できないタイプです"
    end

    puts "delete message"
    m.delete
  end
end


