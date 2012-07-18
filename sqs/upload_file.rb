# Copyright 2011-2012 Amazon.com, Inc. or its affiliates. All Rights Reserved.
#
# Licensed under the Apache License, Version 2.0 (the "License"). You
# may not use this file except in compliance with the License. A copy of
# the License is located at
#
#     http://aws.amazon.com/apache2.0/
#
# or in the "license" file accompanying this file. This file is
# distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF
# ANY KIND, either express or implied. See the License for the specific
# language governing permissions and limitations under the License.

require "samples_config"

def upload_file(bucket_name, file_name)

  # get an instance of the S3 interface using the default configuration
  s3 = AWS::S3.new

  # create a bucket
  b = s3.buckets[bucket_name] 
  unless b.exists?
    b = s3.buckets.create(bucket_name)
  end
  # upload a file
  basename = File.basename(file_name)
  o = b.objects[basename]
  o.write(:file => file_name)

  puts "Uploaded #{file_name} to:"
  puts o.public_url

  # generate a presigned URL
  dl_url =  o.url_for(:read)
  [bucket_name, file_name, dl_url]
end

def download_file(bucket_name, file_name, tempfile_name)
  s3 = AWS::S3.new

  if b = s3.buckets[bucket_name]
    File.open(tempfile_name, "w") do |f|
      f.write(b.objects[file_name].read)
    end
    tempfile_name
  else
    puts "bucketが存在していない"
    nil
  end
end
