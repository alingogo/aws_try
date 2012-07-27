require "rubygems"
require "aws-sdk"


require File.join(File.dirname(__FILE__) + "/../samples_config")

v = '16'
swf = AWS::SimpleWorkflow.new
domain = swf.domains['ExampleWorkflow']

workflow_type = domain.workflow_types['my-long-processes', v]
activity_type = domain.activity_types['do-something', v]

domain.activity_tasks.poll('my-task-list') do |activity_task|
  case activity_task.activity_type.name
  when 'do-something'
    activity_task.complete! :result => 'OK'
  else
    activity_task.fail! :reason => 'unknown activity task type'
  end
end

domain.activity_tasks.poll('my-task-list') do |activity_task|
  begin
    activity_task.record_heartbeat! :details => '25%'
    activity_task.record_heartbeat! :details => '50%'
    activity_task.record_heartbeat! :details => '75%'
  rescue ActivityTask::CancelRequestedError
    activity_task.cancel!
  end
end
