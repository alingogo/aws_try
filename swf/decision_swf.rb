require "rubygems"
require "aws-sdk"


require File.join(File.dirname(__FILE__) + "/../samples_config")

v = '16'
swf = AWS::SimpleWorkflow.new
domain = swf.domains['ExampleWorkflow']

workflow_type = domain.workflow_types['my-long-processes', v]
activity_type = domain.activity_types['do-something', v]


domain.decision_tasks.poll('my-task-list') do |task|
    task.new_events.each do |event|
      case event.event_type
      when 'WorkflowExecutionStarted'
        task.schedule_activity_task(activity_type, :input => 'abc xyz')
      when 'ActivityTaskCompleted'
        task.complete_workflow_execution :result => event.attributes.result
      end
    end
end
