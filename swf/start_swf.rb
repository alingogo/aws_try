require "rubygems"
require "aws-sdk"

require File.join(File.dirname(__FILE__) + "/../samples_config")

v = '16'
swf = AWS::SimpleWorkflow.new
domain = swf.domains['ExampleWorkflow']

=begin
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
=end

workflow_type = domain.workflow_types['my-long-processes', v]
activity_type = domain.activity_types['do-something', v]

workflow_execution = workflow_type.start_execution :input => '...'

puts workflow_execution.workflow_id
puts workflow_execution.run_id

puts domain.decision_tasks.count('my-task-list').to_i
puts domain.activity_tasks.count('my-task-list').to_i
