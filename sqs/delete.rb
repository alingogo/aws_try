require "samples_config"

AMAZON_SQS_TEST_QUEUE = "SQS-Test-Queue-Ruby"

def delete_buckets

  # get an instance of the S3 interface using the default configuration
  s3 = AWS::S3.new

  s3.buckets.each do |b|
    if b.name.include?("bucket")
      puts b.name
      b.delete!
    end
  end
end

def delete_messages
  sqs = AWS::SQS.new

  queue = sqs.queues.named(AMAZON_SQS_TEST_QUEUE)

  flag = true
  while flag
    m = queue.receive_message
    if !m.nil?
      m.delete
    else
      flag = false
    end
  end
  
end

if ARGV[0] == "buckets"
  delete_buckets
elsif ARGV[0] == "messages"
  delete_messages
end

