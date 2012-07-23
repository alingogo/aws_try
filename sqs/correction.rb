#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

require "rubygems"
require "aws-sdk"
require File.join(File.dirname(__FILE__), "samples_config")
require File.join(File.dirname(__FILE__), "upload_file")

AMAZON_SQS_TEST_QUEUE = "Correction-SQS-Test-Queue"
SQS_QUEUE_PROCESS     = "Process-SQS-Test-Queue"

def image_correction(message)
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

  correction_file.gsub(/tmp\//,"")
end

def send_m(mbody, cfile, q)
  
  mbody[:file_name]   = cfile

  sent_message = q.send_message(mbody.to_json)
  puts "message_id: " + sent_message.message_id
end


sqs = AWS::SQS.new

queue     = sqs.queues.named(AMAZON_SQS_TEST_QUEUE)
queue_pro = sqs.queues.named(SQS_QUEUE_PROCESS)

20.times do |i|
  sleep 3
  puts "waiting message in 3 seconds"
  m = queue.receive_message
  if !m.nil?
    mbody = JSON.parse(m.body)
    puts "***#{mbody['time']}番目のメッセージを処理する***"
    puts "message body: #{m.body}"

    cfile = image_correction(mbody)
    send_m(mbody, cfile, queue_pro)
    m.delete
  end
end
