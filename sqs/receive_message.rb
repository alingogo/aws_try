#!/usr/bin/ruby

require "rubygems"
require "aws-sdk"
require "samples_config"
require "upload_file"
require "pp"
require "timeout"

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

  if message["time"] == 5
    sleep 40
  end

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
time_flag = true
#while flag
32.times do |i|
  sleep 3
  puts "waiting message"
  m = queue.receive_message(:attributes => [:all])
  if !m.nil?
    mbody = JSON.parse(m.body)

    rc =  m.receive_count
    puts "approximate_receive_count:  #{rc}"

    if rc > 1
      puts "重複処理messageを発見"
    else
      begin
        timeout(30) do
          image_deal(mbody)
        end
      rescue Timeout::Error
        puts "Timeout発生"
        time_flag = false
      end
    end

    puts "***#{mbody['time']}番目のメッセージを処理する***"
    puts "message body: #{m.body}"

    puts "delete message"
    m.delete if time_flag
    time_flag = true
#    flag = false
  end
end


