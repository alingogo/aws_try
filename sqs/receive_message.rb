#!/usr/bin/ruby

require "rubygems"
require "aws-sdk"
require "samples_config"
require "upload_file"
require "pp"

AMAZON_SQS_TEST_QUEUE = "SQS-Test-Queue-Ruby"
SQS_TEST_MESSAGE = 'This is a test message.'



def image_deal(message)
  result = image_correction(message)
  image_proccess(message, result)
end

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

def image_proccess(message, result)
  str = ""
  b = message["bucket_name"]
  temp = "tmp/tempfile_#{b}.txt"

  download_file(b, result, temp)

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

#flag = true
#while flag
22.times do |i|
  sleep 3
  puts "waiting message"
  m = queue.receive_message
  if !m.nil?
    mbody = JSON.parse(m.body)
    image_deal(mbody)

    puts "***#{mbody['time']}番目のメッセージを処理する***"
    puts "message body: #{m.body}"

    puts "delete message"
    m.delete
#    flag = false
  end
end


