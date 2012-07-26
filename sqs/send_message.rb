#!/usr/bin/ruby
# -*- encoding: utf-8 -*-
# Copyright 2007 Amazon Technologies, Inc.  Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License. You may obtain a copy of the License at:
#
# http://aws.amazon.com/apache2.0
#
# This file is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and limitations under the License.

require "rubygems"
require "aws-sdk"
require File.join(File.dirname(__FILE__), "../samples_config")
require "upload_file"
require "json"
require "yaml"

AMAZON_SQS_TEST_QUEUE = "SQS-Test-Queue-Ruby"

sqs = AWS::SQS.new

queue = sqs.queues.named(AMAZON_SQS_TEST_QUEUE)

t = (ARGV[0] || 10).to_i
t.times do |i|
  content_id = rand(1000000000)
  bucket_name = "8342_bucket_" + content_id.to_s
  file_name = "sample_original.txt"

  bn, fn, dl_url = upload_file(bucket_name, file_name)

  body = {}
  body[:correction] = { :status => "todo",
                        :bucket_name => bn,
                        :file_name => fn}
  body[:process]    = { :status => "none"}
  body[:time]       = i
  yaml_file = File.join(File.dirname(__FILE__), "tmp/#{content_id.to_s}.yml")
  File.open(yaml_file, "w") do |f|
    f.write(YAML.dump(body))
  end

  m = {}
  m['content_id'] = content_id
  sent_message = queue.send_message(m.to_json)
  puts (i+1).to_s + "回目に、メッセージを送信しました"
  puts "message_id: " + sent_message.message_id
  puts "****************************************"
  puts ""
end
