require "rubygems"
require "aws-sdk"


require File.expand_path(File.dirname(__FILE__) + "../samples_config")

v = '14'
swf = AWS::SimpleWorkflow.new
domain = swf.domains['ExampleWorkflow']

workflow_type = domain.workflow_types.create('my-long-processes', v,
    :default_task_list => 'my-task-list',
    :default_child_policy => :request_cancel,
    :default_task_start_to_close_timeout => 3600,
    :default_execution_start_to_close_timeout => 24 * 3600)

activity_type = domain.activity_types.create('do-something', v, 
    :default_task_list => 'my-task-list',
    :default_task_heartbeat_timeout => 900,
    :default_task_schedule_to_start_timeout => 60,
    :default_task_schedule_to_close_timeout => 3660,
    :default_task_start_to_close_timeout => 3600)

workflow_type = domain.workflow_types['my-long-processes', v]
workflow_execution = workflow_type.start_execution :input => '...'

puts workflow_execution.workflow_id #=> "5abbdd75-70c7-4af3-a324-742cd29267c2"
puts workflow_execution.run_id #=> "325a8c34-d133-479e-9ecf-5a61286d165f"

#puts domain.decision_tasks.count('my-task-list').to_i


domain.decision_tasks.poll('my-task-list') do |task|
    task.new_events.each do |event|
      case event.event_type
      when 'WorkflowExecutionStarted'
puts "WES"
        task.schedule_activity_task(activity_type, :input => 'abc xyz')
      when 'ActivityTaskCompleted'
        task.complete_workflow_execution :result => event.attributes.result
      end
    end
end

at = domain.activity_tasks.poll('my-task-list') 
puts at.activity_type.name
=begin
do |activity_task|
  case activity_task.activity_type.name
  when 'do-something' 
    activity_task.complete! :result => 'OK'
  else
    activity_task.fail! :reason => 'unknown activity task type'
  end
end

=begin
  domain.activity_tasks.poll('my-task-list') do |activity_task|
    begin
      activity_task.record_heartbeat! :details => '25%'
      activity_task.record_heartbeat! :details => '50%'
      activity_task.record_heartbeat! :details => '75%'
    rescue ActivityTask::CancelRequestedError
      activity_task.cancel!
    end
  end
=end

def upload
 bucket_name = 'test2'
 file_name = 'hello.txt'
 #get an instance of the S3 interface using the default configuration
 s3 = AWS::S3.new

 # create a bucket
 b = s3.buckets.create(bucket_name)

 # upload a file
 basename = File.basename(file_name)
 o = b.objects[basename]
 o.write(:file => file_name)

 puts "Uploaded #{file_name} to:"
 puts o.public_url

 # generate a presigned URL
 puts "\nUse this URL to download the file:"
 puts o.url_for(:read)

 puts "(press any key to delete the object)"
 $stdin.getc

 o.delete
end
