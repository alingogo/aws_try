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
require "samples_config"
require "pp"

AMAZON_SQS_TEST_QUEUE = "SQS-Test-Queue-Ruby"
SQS_TEST_MESSAGE = 'This is a test message.'


sqs = AWS::SQS.new

queue = sqs.queues.create('test_for_create4',
          :visibility_timeout => 60,
          :maximum_message_size => 30000,
          :delay_seconds => 30,
          :message_retention_period => 12000)

pp queue.approximate_number_of_messages

queue.delete
=begin
queue = sqs.queues.named(AMAZON_SQS_TEST_QUEUE)

queue.send_message(SQS_TEST_MESSAGE)

sleep 10

queue.receive_message{|m| pp m.body}
=end

#pp sqs.queues.url_for(AMAZON_SQS_TEST_QUEUE)
#sqs.queues.each{|q| pp q}
#pp sqs.queues.collect(&:url)
