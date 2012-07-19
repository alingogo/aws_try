require "rubygems"
require "aws-sdk"

client = AWS::SQS::Client.new(
            :access_key_id => ENV["ACCESS_KEY_ID"],
            :secret_access_key => ENV["SECRET_ACCESS_KEY"],
            :sqs_endpoint      => ENV["SQS_ENDPOINT"])

puts client.get_queue_url(:queue_name => "SQS-Test-Queue-Ruby")


=begin

# 実行すると、以下のエラーが出た
# まさか、Ruby on Rails専用ツールか


$ ruby test.rb 
/usr/lib64/ruby/gems/1.8/gems/aws-sdk-1.5.6/lib/aws/core/credential_providers.rb:41:in `credentials':  (AWS::Errors::MissingCredentialsError)
Missing Credentials.

Unable to find AWS credentials.  You can configure your AWS credentials
a few different ways:

* Call AWS.config with :access_key_id and :secret_access_key

* Export AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY to ENV

* On EC2 you can run instances with an IAM instance profile and credentials 
  will be auto loaded from the instance metadata service on those
  instances.

* Call AWS.config with :credential_provider.  A credential provider should
  either include AWS::Core::CredentialProviders::Provider or respond to
  the same public methods.

= Ruby on Rails

In a Ruby on Rails application you may also specify your credentials in 
the following ways:

* Via a config initializer script using any of the methods mentioned above
  (e.g. RAILS_ROOT/config/initializers/aws-sdk.rb).

* Via a yaml configuration file located at RAILS_ROOT/config/aws.yml.
  This file should be formated like the default RAILS_ROOT/config/database.yml
  file.

	from /usr/lib64/ruby/gems/1.8/gems/aws-sdk-1.5.6/lib/aws/core/credential_providers.rb:51:in `access_key_id'
	from /usr/lib64/ruby/gems/1.8/gems/aws-sdk-1.5.6/lib/aws/core/client.rb:435:in `build_request'
	from /usr/lib64/ruby/gems/1.8/gems/aws-sdk-1.5.6/lib/aws/core/client.rb:389:in `send'
	from /usr/lib64/ruby/gems/1.8/gems/aws-sdk-1.5.6/lib/aws/core/client.rb:389:in `client_request'
	from /usr/lib64/ruby/gems/1.8/gems/aws-sdk-1.5.6/lib/aws/core/response.rb:160:in `call'
	from /usr/lib64/ruby/gems/1.8/gems/aws-sdk-1.5.6/lib/aws/core/response.rb:160:in `rebuild_request'
	from /usr/lib64/ruby/gems/1.8/gems/aws-sdk-1.5.6/lib/aws/core/response.rb:104:in `initialize'
	from /usr/lib64/ruby/gems/1.8/gems/aws-sdk-1.5.6/lib/aws/core/client.rb:166:in `new'
	from /usr/lib64/ruby/gems/1.8/gems/aws-sdk-1.5.6/lib/aws/core/client.rb:166:in `new_response'
	from /usr/lib64/ruby/gems/1.8/gems/aws-sdk-1.5.6/lib/aws/core/client.rb:389:in `client_request'
	from /usr/lib64/ruby/gems/1.8/gems/aws-sdk-1.5.6/lib/aws/core/client.rb:293:in `log_client_request'
	from /usr/lib64/ruby/gems/1.8/gems/aws-sdk-1.5.6/lib/aws/core/client.rb:377:in `client_request'
	from /usr/lib64/ruby/gems/1.8/gems/aws-sdk-1.5.6/lib/aws/core/client.rb:275:in `return_or_raise'
	from /usr/lib64/ruby/gems/1.8/gems/aws-sdk-1.5.6/lib/aws/core/client.rb:376:in `client_request'
	from (eval):3:in `get_queue_url'
	from test.rb:9


=end
