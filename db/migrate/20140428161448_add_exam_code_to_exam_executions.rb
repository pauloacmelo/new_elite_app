class AddExamCodeToExamExecutions < ActiveRecord::Migration
  def change
    add_column :exam_executions, :exam_code, :string
    ExamExecution.all.each{|e| e.update_column(:exam_code, e.exam.code)}
  end
end