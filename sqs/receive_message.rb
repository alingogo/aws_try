#!/usr/bin/ruby
# -*- encoding: utf-8 -*-

require "rubygems"
require "aws-sdk"
require File.join(File.dirname(__FILE__), "../samples_config")
require File.join(File.dirname(__FILE__), "upload_file")
require "pp"

AMAZON_SQS_TEST_QUEUE = "SQS-Test-Queue-Ruby"
SQS_TEST_MESSAGE = 'This is a test message.'


def image_correction(mes)
  str = ""
  m = mes.dup
  message = m["correction"]
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

  m.merge!("correction" => {:status => "done", :update => Time.now.to_s})
  m.merge!("process" => {:status => "todo", :file_name => fn})
  m
end

def image_process(mes)
  str = ""
  m = mes.dup
  message = m['process']
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

  m.merge!("process" => {:status => "done", :update => Time.now.to_s})

  m
end

def send_message(q, m)
  pp m
  if m.nil?
    return
  elsif m['correction'][:status] == 'done' && m['process'][:status] == 'todo'
    q.send_message(m.to_json)
  else
    puts "send_message error"
  end
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

    new_mbody = if mbody['correction']['status'] == 'todo'
                  image_correction(mbody)
                elsif mbody['correction']['status'] == 'todo'
                  image_process(mbody)
                else
                  nil
                end

    send_message(queue, new_mbody)

    puts "delete message"
    m.delete
  end
end


